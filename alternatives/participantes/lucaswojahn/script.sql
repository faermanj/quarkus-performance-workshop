SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE UNLOGGED TABLE IF NOT EXISTS clientes(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0 NOT NULL
    CONSTRAINT check_limit CHECK (current_balance >= -limit)
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions(
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes (id),
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT current_timestamp
);

CREATE OR REPLACE FUNCTION create_transaction(
    p_cliente_id INTEGER,
    p_amount INTEGER,
    p_kind CHAR(1),
    p_description VARCHAR(10)
) RETURNS INTEGER
    LANGUAGE plpgsql
AS $$
DECLARE
    v_limit INTEGER DEFAULT 0;
    v_current_balance INTEGER DEFAULT 0;
BEGIN

    IF p_amount < 0 THEN
        RAISE EXCEPTION 'Transaction amount cannot be negative!';
    END IF;


    IF p_kind = 'c' THEN
        UPDATE clientes SET current_balance = current_balance + p_amount WHERE id = p_cliente_id RETURNING current_balance INTO v_current_balance;
    ELSIF p_kind = 'd' THEN
        SELECT limit, current_balance INTO v_limit, v_current_balance FROM clientes WHERE id = p_cliente_id FOR UPDATE;
        IF (v_current_balance + v_limit - p_amount) < 0 THEN
            RAISE EXCEPTION 'Debit exceeds customer limit and balance!';
        ELSE
            UPDATE clientes SET current_balance = current_balance - p_amount WHERE id = p_cliente_id RETURNING current_balance INTO v_current_balance;
        END IF;
    END IF;

    INSERT INTO transactions (cliente_id, amount, kind, description)
    VALUES (p_cliente_id, p_amount, p_kind, p_description);
    RETURN v_current_balance;
END;
$$;

DO $$
    BEGIN
        INSERT INTO clientes (nome, limit)
        VALUES
            ('o barato sai caro', 1000 * 100),
            ('zan corp ltda', 800 * 100),
            ('les cruders', 10000 * 100),
            ('padaria joia de cocaia', 100000 * 100),
            ('kid mais', 5000 * 100);
    END;
$$;