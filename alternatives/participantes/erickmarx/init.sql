SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';

CREATE UNLOGGED TABLE customers (
	id SERIAL PRIMARY KEY,
	current_balance INTEGER NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	customerId INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_cliente_transacao_id
		FOREIGN KEY (customerId) REFERENCES customers(id)
);

CREATE INDEX ix_transacao_idcliente ON transactions
(
    customerId ASC
);

DO $$
BEGIN
	INSERT INTO customers (limit, current_balance)
	VALUES
		(100000, 0),
		(80000, 0),
		(1000000, 0),
		(10000000, 0),
		(500000, 0);
END;
$$;

CREATE OR REPLACE FUNCTION debit(
	customerId INT,
	amount INT,
	description VARCHAR(10))
RETURNS TABLE (current_balanceFinal INT, error BOOL)
LANGUAGE plpgsql
AS $$
DECLARE
	limitAtual int;
	current_balanceAtual int;
BEGIN
	PERFORM pg_advisory_xact_lock(customerId);
	SELECT 
		c.limit,
		c.current_balance 
	INTO
		limitAtual,
		current_balanceAtual
	FROM customers c
	WHERE c.id = customerId;

	IF current_balanceAtual - amount < limitAtual * -1 THEN
		RETURN QUERY 
			SELECT
				current_balance,
				TRUE -- current_balance insuficiente
			FROM customers
			WHERE id = customerId;
	ELSE
		INSERT INTO transactions
			VALUES(DEFAULT, customerId, amount, 'd', description, DEFAULT);
		
		RETURN QUERY
			UPDATE customers
			SET current_balance = current_balance - amount
			WHERE id = customerId
			RETURNING current_balance, FALSE;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION credit(
	customerId INT,
	amount INT,
	description VARCHAR(10))
RETURNS TABLE (current_balanceFinal INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(customerId);

	INSERT INTO transactions
		VALUES(DEFAULT, customerId, amount, 'c', description, DEFAULT);

	RETURN QUERY
		UPDATE customers
		SET current_balance = current_balance + amount
		WHERE id = customerId
		RETURNING current_balance;
END;
$$;
