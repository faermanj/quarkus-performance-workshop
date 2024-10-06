CREATE table
  clientes (
    id int primary key,
    limit int not null default 0,
    current_balance int not null default 0
  );

-- ALTER TABLE clientes ADD CONSTRAINT check_limit CHECK (current_balance >= (limit * -1));

CREATE table
  transactions (
    id int auto_increment primary key,
    cliente_id int not null,
    amount int not null,
    kind varchar(1) not null,
    description varchar(10) not null,
    submitted_at DATETIME(6) not null,
    index (cliente_id) USING HASH
  );

START TRANSACTION;

insert into clientes(id, limit, current_balance)
values
  (1, 1000 * 100, 0),
  (2, 800 * 100, 0),
  (3, 10000 * 100, 0),
  (4, 100000 * 100, 0),
  (5, 5000 * 100, 0);

-- insert into transactions (cliente_id, amount, kind, description, submitted_at)
-- values
--  (1, 0, 'c', 'init', now(6)),
--  (2, 0, 'c', 'init', now(6)),
--  (3, 0, 'c', 'init', now(6)),
--  (4, 0, 'c', 'init', now(6)),
--  (5, 0, 'c', 'init', now(6));

COMMIT;

DELIMITER //

CREATE PROCEDURE proc_transacao (
  IN p_cliente_id int,
  IN amount int,
  IN kind varchar(1),
  IN description varchar(10),
  IN submitted_at TIMESTAMP(6),
  OUT json_body TEXT,
  OUT status_code INT
) BEGIN 

DECLARE v_current_balance INT;
DECLARE v_limit INT;
DECLARE v_error_message VARCHAR(255) DEFAULT 'An error occurred during the transaction';

DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN
  GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
  SET json_body = JSON_OBJECT ('error', v_error_message);
  SET status_code = 422;
  ROLLBACK;
END;

SET autocommit=0;
START TRANSACTION READ WRITE;

SELECT current_balance, limit 
  INTO v_current_balance, v_limit
  FROM clientes
  WHERE id = p_cliente_id
  FOR UPDATE;

IF kind = 'c' THEN
  UPDATE clientes
    SET current_balance = v_current_balance + amount
    WHERE id = p_cliente_id;
  INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at)
  VALUES (p_cliente_id, amount, kind, description, now(6));
    SET json_body = JSON_OBJECT ('current_balance', CAST(v_current_balance + amount as INT), 'limit', CAST(v_limit as INT));
    SET status_code = 200;
ELSE
  IF v_current_balance - amount < -1 * v_limit THEN
    SET json_body = JSON_OBJECT ('error', 'Saldo insuficiente');
    SET status_code = 422;
    ROLLBACK;
  ELSE
    UPDATE clientes
      SET current_balance = v_current_balance - amount
      WHERE id = p_cliente_id;
    INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at)
      VALUES (p_cliente_id, amount, kind, description, now(6));
    SET json_body = JSON_OBJECT ('current_balance', CAST(v_current_balance - amount as INT), 'limit', CAST(v_limit as INT));
    SET status_code = 200;
  END IF;
END IF;
COMMIT;
END//

DELIMITER //
CREATE PROCEDURE proc_balance (
  IN p_cliente_id INT,
  OUT json_body TEXT,
  OUT status_code INT
) BEGIN 

DECLARE v_current_balance INT DEFAULT 0;
DECLARE v_limit INT DEFAULT -1;

SET autocommit=0;
START TRANSACTION READ ONLY;

SELECT current_balance, limit 
  INTO v_current_balance, v_limit
  FROM clientes
  WHERE id = p_cliente_id;

SET json_body = JSON_OBJECT(
    'current_balance', JSON_OBJECT(
        'total', CAST(v_current_balance as INT),
        'limit', CAST(v_limit as INT),
        'date_balance', DATE_FORMAT(NOW(6), '%Y-%m-%d %H:%i:%s.%f')
    ),
    'recent_transactions', (
        SELECT IFNULL(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'amount', CAST(amount as INT),
                    'kind', kind,
                    'description', description,
                    'submitted_at', DATE_FORMAT(submitted_at, '%Y-%m-%d %H:%i:%s.%f')
                )
            ),
            JSON_ARRAY()
        )
        FROM (
            SELECT amount, kind, description, submitted_at
            FROM transactions
            WHERE cliente_id = p_cliente_id
            ORDER BY submitted_at DESC
            LIMIT 10
        ) AS limitd_transactions
    )
);


  SET status_code = 200;
  COMMIT;
END//


