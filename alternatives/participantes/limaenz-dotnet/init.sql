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

CREATE UNLOGGED TABLE cliente (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transacao (
    id SERIAL PRIMARY KEY,
    idCliente INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    realizadoEm TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transacao_idCliente ON transacao (idCliente ASC);

INSERT INTO cliente (id, limit, current_balance)
VALUES 
    (1, 1000 * 100, 0),
    (2, 800 * 100, 0),
    (3, 10000 * 100, 0),
    (4, 100000 * 100, 0),
    (5, 5000 * 100, 0);

CREATE OR REPLACE FUNCTION realizar_credito(id_cliente INT, novo_amount INT, description_cd VARCHAR(10))
RETURNS TABLE (current_balanceAtual INT, erro BOOL)
LANGUAGE plpgsql 
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(id_cliente);
    INSERT INTO transacao (amount, kind, description, realizadoEm, idCliente)
    VALUES (novo_amount, 'c', description_cd, NOW(), id_cliente);

    RETURN QUERY
    UPDATE cliente
    SET current_balance = current_balance + novo_amount
    WHERE id = id_cliente
	RETURNING current_balance, FALSE;
END;
$$;

CREATE OR REPLACE FUNCTION realizar_debito(id_cliente INT, novo_amount INT, description_db VARCHAR(10))
RETURNS TABLE (current_balanceAtual INT, erro BOOL)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(id_cliente);
    IF (SELECT (current_balance - novo_amount) >= (limit * -1) from cliente where id = id_cliente) THEN 
        INSERT INTO transacao (amount, kind, description, realizadoEm, idCliente)
        VALUES (novo_amount, 'd', description_db, NOW(), id_cliente);

        UPDATE cliente
        SET current_balance = current_balance - novo_amount
        WHERE id = id_cliente;

        RETURN QUERY SELECT current_balance, FALSE FROM cliente WHERE id = id_cliente;
    ELSE
        RETURN QUERY SELECT current_balance, TRUE FROM cliente WHERE id = id_cliente;
    END IF;
END;
$$;


