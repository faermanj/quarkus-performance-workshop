-- general

SET TIME ZONE 'UTC';

-- tables

CREATE TABLE current_balances (
    cliente_id INTEGER PRIMARY KEY NOT NULL,
    limit INT NOT NULL,
    current_balance INT NOT NULL
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    description VARCHAR(10) NOT NULL,
    kind CHAR(1) NOT NULL,
    amount INT NOT NULL,
    realizado_em TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- indexes

CREATE INDEX idx_transacaos_cliente_id ON transactions (cliente_id, id DESC);

-- functions

CREATE OR REPLACE FUNCTION fn_crebito(fn_cliente_id INT, fn_description VARCHAR(10), fn_kind CHAR(1), fn_amount INT)
RETURNS TABLE (fn_res_current_balance_final INT, fn_res_code INT)
AS $$
DECLARE v_current_balance INT; v_limit INT;
BEGIN
    PERFORM pg_advisory_xact_lock(fn_cliente_id);
	
    IF fn_kind = 'c' THEN 
        INSERT INTO transactions (cliente_id, description, kind, amount) 
            VALUES(fn_cliente_id, fn_description, 'c', fn_amount);

        RETURN QUERY
            UPDATE current_balances
            SET current_balance = current_balance + fn_amount
            WHERE cliente_id = fn_cliente_id
            RETURNING current_balance, 1;
    ELSE
        SELECT limit, current_balance INTO v_limit, v_current_balance FROM current_balances WHERE cliente_id = fn_cliente_id;
        IF NOT FOUND THEN
            RETURN QUERY
                SELECT 0, 3;
        END IF;

        IF v_current_balance - fn_amount >= v_limit * -1 THEN 
            INSERT INTO transactions (cliente_id, description, kind, amount) 
            VALUES(fn_cliente_id, fn_description, fn_kind, fn_amount);
            
            RETURN QUERY
                UPDATE current_balances
                SET current_balance = current_balance - fn_amount
                WHERE cliente_id = fn_cliente_id
                RETURNING current_balance, 1;
        ELSE
            RETURN QUERY
                SELECT v_current_balance, 2;
        END IF;
    END IF;
END;
$$
LANGUAGE plpgsql;

-- insert init data

INSERT INTO current_balances (cliente_id, limit, current_balance)
VALUES 
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);
