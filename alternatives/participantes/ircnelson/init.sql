CREATE UNLOGGED TABLE clientes (
	id SERIAL CONSTRAINT pk_clientes PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL CONSTRAINT pk_transactions PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
);

CREATE INDEX ix_transactions_submitted_at ON transactions (submitted_at DESC) INCLUDE (amount, kind, description);
CREATE INDEX ix_clientes_balance ON clientes (id) INCLUDE (limit, current_balance);

DO $$
BEGIN
	INSERT INTO clientes (nome, limit, current_balance)
	VALUES
		('o barato sai caro', 1000 * 100, 0),
		('zan corp ltda', 800 * 100, 0),
		('les cruders', 10000 * 100, 0),
		('padaria joia de cocaia', 100000 * 100, 0),
		('kid mais', 5000 * 100, 0);
END;
$$;

/*
Code table
---------------------------------
| Code  | Reason 				|
| 0		| Ok	 				|
| 1		| Insufficient funds	|
---------------------------------
*/

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (code INT, limit INT, current_balance INT)
LANGUAGE plpgsql
AS $$
DECLARE
	current_balance_atual INT;
	novo_current_balance INT;
	limit_atual INT;
BEGIN
	SELECT 
		clientes.limit,
		clientes.current_balance,
		clientes.current_balance - amount_tx
	INTO
		limit_atual,
		current_balance_atual,
		novo_current_balance
	FROM clientes
	WHERE clientes.id = cliente_id_tx AND (clientes.current_balance - amount_tx >= (clientes.limit * -1))
	FOR UPDATE;

	IF limit_atual IS NULL THEN
		RETURN QUERY
			SELECT 1, 0, 0;
	ELSE
		UPDATE clientes
		SET current_balance = novo_current_balance
		WHERE clientes.id = cliente_id_tx;
		
		INSERT INTO transactions VALUES(DEFAULT, cliente_id_tx, amount_tx, 'd', description_tx, DEFAULT);

		RETURN QUERY
			SELECT 0, limit_atual, novo_current_balance;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (code INT, limit INT, current_balance INT)
LANGUAGE plpgsql
AS $$
DECLARE
	rec RECORD;
BEGIN
	UPDATE clientes
	SET current_balance = clientes.current_balance + amount_tx
	WHERE clientes.id = cliente_id_tx
	RETURNING clientes.limit, clientes.current_balance
	INTO rec;

	INSERT INTO transactions VALUES(DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, DEFAULT);

	RETURN QUERY 
		SELECT 0, rec.limit, rec.current_balance;
END;
$$;
