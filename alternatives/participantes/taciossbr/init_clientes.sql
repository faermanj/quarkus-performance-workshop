CREATE TABLE members (
    id INT PRIMARY KEY,
    limit BIGINT NOT NULL,
    current_balance BIGINT NOT NULL DEFAULT '0'
    -- TODO ver se o INTEGER e suficiente
);

CREATE TYPE kind_transacao AS ENUM ('c', 'd');
CREATE TABLE transactions(
    id SERIAL PRIMARY KEY, -- TODO ver se precisa disso
    amount BIGINT NOT NULL,
    kind kind_transacao NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    cliente_id INT NOT NULL REFERENCES members(id)
);

INSERT INTO members VALUES
('1', '100000', '0'),
('2', '80000', '0'),
('3', '1000000', '0'),
('4', '10000000', '0'),
('5', '500000', '0');

CREATE OR REPLACE PROCEDURE insert_transacao(
  pamount BIGINT,
  pkind kind_transacao,
  pdescription VARCHAR(10),
  pcliente_id INTEGER,
  
  INOUT v_current_balance BIGINT DEFAULT NULL,
  INOUT v_limit BIGINT DEFAULT NULL,
  INOUT v_status SMALLINT DEFAULT 0
  -- 0 => OK
  -- 404 => OK
  -- 422 => OK
)
LANGUAGE plpgsql
AS $$
DECLARE
    vcliente_id INTEGER := NULL;
BEGIN
    SELECT id FROM members
    INTO vcliente_id
    WHERE id = pcliente_id
    FOR UPDATE;

    if vcliente_id is NULL then
        v_status := 404;
        return;
    end if;

    if pkind = 'c' then
          UPDATE members
          SET current_balance = current_balance + pamount
          WHERE id = pcliente_id
          RETURNING current_balance, limit INTO v_current_balance, v_limit;
    elsif pkind = 'd' then
          UPDATE members
          SET current_balance = current_balance - pamount
          WHERE id = pcliente_id AND current_balance - pamount >= -limit
          RETURNING current_balance, limit INTO v_current_balance, v_limit;
          if v_current_balance is null then
              v_status := 422;
              return;
          end if;
    end if;
    INSERT INTO transactions
    (amount, kind, description, cliente_id)
    VALUES
    (pamount, pkind, pdescription, pcliente_id);
END;
$$;


CREATE OR REPLACE PROCEDURE balance(
  cid INTEGER,
  INOUT cliente refcursor,
  INOUT transactions refcursor
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN cliente FOR
    SELECT id, limit, current_balance AS total FROM members
    WHERE id = cid;

    OPEN transactions FOR
    SELECT amount, kind, description, submitted_at FROM transactions
    WHERE cliente_id = cid
    ORDER BY id DESC
    LIMIT 10;
END;
$$;

CREATE INDEX IF NOT EXISTS current_balance_index ON members(current_balance);
CREATE INDEX IF NOT EXISTS id_trc ON transactions(id DESC);
CREATE INDEX IF NOT EXISTS cid_transactions ON transactions(cliente_id);

