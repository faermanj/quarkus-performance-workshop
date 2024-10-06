
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
	nome VARCHAR(50) NOT NULL,
	current_balance INTEGER NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transacao (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_cliente_transacao_id
		FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE INDEX ix_transacao_idcliente ON transacao
(
    cliente_id ASC
);

DO $$
BEGIN
	INSERT INTO cliente (nome, limit, current_balance)
	VALUES
		('ed', 100000, 0),
		('li', 80000, 0),
		('ci', 1000000, 0),
		('ev', 10000000, 0),
		('jo', 500000, 0);
END;
$$;

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	possui_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
	current_balance_atual int;
	limit_atual int;
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);
	SELECT 
		c.limit,
		COALESCE(c.current_balance, 0)
	INTO
		limit_atual,
		current_balance_atual
	FROM cliente c
	WHERE c.id = cliente_id_tx;

	IF current_balance_atual - amount_tx >= limit_atual * -1 THEN
		INSERT INTO transacao
			VALUES(DEFAULT, cliente_id_tx, amount_tx, 'd', description_tx, NOW());
		
		UPDATE cliente
		SET current_balance = current_balance - amount_tx
		WHERE id = cliente_id_tx;

		RETURN QUERY
			SELECT
				current_balance,
				FALSE,
				'ok'::VARCHAR(20)
			FROM cliente
			WHERE id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT
				current_balance,
				TRUE,
				'current_balance insuficente'::VARCHAR(20)
			FROM cliente
			WHERE id = cliente_id_tx;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	possui_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);

	INSERT INTO transacao
		VALUES(DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

	RETURN QUERY
		UPDATE cliente
		SET current_balance = current_balance + amount_tx
		WHERE id = cliente_id_tx
		RETURNING current_balance, FALSE, 'ok'::VARCHAR(20);
END;
$$;
