CREATE TABLE IF NOT EXISTS clientes
(
    id          int not null Primary key,
    limit      int not null default 0,
    current_balance       int not null default 0
);


insert into clientes (id, limit, current_balance) values(1, 100000, 0);
insert into clientes (id, limit, current_balance) values(2, 80000, 0);
insert into clientes (id, limit, current_balance) values(3, 1000000, 0);
insert into clientes (id, limit, current_balance) values(4, 10000000, 0);
insert into clientes (id, limit, current_balance) values(5, 500000, 0);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions
(
    id           varchar(100) not null,
    id_cliente   INT NOT NULL,
    amount        INT NOT NULL,
    kind         VARCHAR(1) NOT NULL,
    description    VARCHAR(100) NOT NULL,
    ultimo_current_balance INT,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

ALTER TABLE transactions SET (autovacuum_enabled = false);


-- 
-- credito
-- 
CREATE OR REPLACE FUNCTION func_credito(
    pid VARCHAR(30),
    pid_cliente INT,
    pamount INT,
    pdescription VARCHAR(10),
    pcreated_at TIMESTAMPTZ
)
RETURNS TABLE (current_balance_atual INT, limit_atual INT)
LANGUAGE plpgsql
AS $$
DECLARE
    var_current_balance INT;
BEGIN
    LOCK TABLE clientes, transactions IN ACCESS EXCLUSIVE MODE;

    INSERT INTO transactions (id, id_cliente, amount, kind, description, ultimo_current_balance, created_at)
    VALUES (pid, pid_cliente, pamount, 'c', pdescription, var_current_balance, pcreated_at);

    RETURN QUERY
        UPDATE clientes SET current_balance = current_balance + pamount WHERE id = pid_cliente
        RETURNING current_balance, limit;
END;
$$;



-- 
-- debito
-- 
CREATE OR REPLACE FUNCTION func_debito(
    pid VARCHAR(30),
    pid_cliente INT,
    pamount INT,
    pdescription VARCHAR(10),
    pcreated_at TIMESTAMPTZ
)
RETURNS TABLE (current_balance_atual INT, limit_atual INT) 
LANGUAGE plpgsql 
AS $$
DECLARE
    var_current_balance INT;
    var_limit INT;
BEGIN
    LOCK TABLE clientes, transactions IN ACCESS EXCLUSIVE MODE;

    SELECT c.current_balance, c.limit 
    INTO var_current_balance, var_limit
    FROM clientes c
    WHERE c.id = pid_cliente;

    IF (var_current_balance - pamount >= -var_limit) THEN


        INSERT INTO transactions (id, id_cliente, amount, kind, description, ultimo_current_balance, created_at)
        VALUES (pid, pid_cliente, pamount, 'd', pdescription, var_current_balance, pcreated_at);

        UPDATE clientes SET current_balance = var_current_balance WHERE id = pid_cliente;

        RETURN QUERY 
            UPDATE clientes SET current_balance = current_balance - pamount WHERE id = pid_cliente
            RETURNING current_balance, limit;

    ELSE
        RAISE EXCEPTION '[001] Cliente não tem limit para a operação';
    END IF;
END;
$$;

