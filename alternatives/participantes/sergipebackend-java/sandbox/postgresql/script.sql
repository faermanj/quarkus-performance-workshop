CREATE UNLOGGED TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL    PRIMARY KEY NOT NULL,
    kind         CHAR(1) NOT NULL,
    description    VARCHAR(10) NOT NULL,
    amount        INTEGER NOT NULL,
    cliente_id   INTEGER NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cliente_id ON transactions(cliente_id);

INSERT INTO members (limit, current_balance)
VALUES
    (100000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);

CREATE OR REPLACE FUNCTION atualizar_current_balance()
RETURNS TRIGGER AS $$
DECLARE
    v_current_balance INTEGER;
    v_limit INTEGER;
BEGIN
     SELECT current_balance, limit INTO v_current_balance, v_limit
     FROM members WHERE id = NEW.cliente_id
     FOR UPDATE;

    IF NEW.kind = 'd' AND (v_current_balance - NEW.amount) < -v_limit THEN
        RAISE EXCEPTION USING
            errcode='23000',
            message='Limite insuficiente';
    END IF;

    UPDATE members SET current_balance =
        CASE WHEN NEW.kind = 'd' THEN current_balance - NEW.amount
            ELSE current_balance + NEW.amount
        END
    WHERE id = NEW.cliente_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER atualizar_current_balance_trigger
    AFTER INSERT ON transactions
    FOR EACH ROW EXECUTE FUNCTION atualizar_current_balance();

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