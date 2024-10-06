CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER 
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE
    transactions
ADD
    CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES clientes (id),
SET
    (autovacuum_enabled = off);

CREATE INDEX ON transactions (cliente_id, submitted_at DESC);

INSERT INTO clientes (nome, limit, current_balance)
VALUES
	('o barato sai caro', 1000 * 100, 0),
	('zan corp ltda', 800 * 100,  0),
	('les cruders', 10000 * 100, 0),
	('padaria joia de cocaia', 100000 * 100, 0),
	('kid mais', 5000 * 100, 0);

CREATE TYPE result_transacao AS (current_balance_atual INT, limit INT);

CREATE OR REPLACE FUNCTION transacao(cliente_id_tx INTEGER, amount_tx INTEGER, kind_tx VARCHAR(1), description_tx VARCHAR(10)) RETURNS result_transacao AS $$
DECLARE
	current_balance INTEGER;
  limit INTEGER;
	current_balance_atual INTEGER;
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);
	SELECT
		COALESCE(c.current_balance, 0),
		c.limit
	INTO
		current_balance,
		limit
	FROM clientes c
	WHERE c.id = cliente_id_tx;

	IF kind_tx = 'd' THEN
		current_balance_atual := current_balance - amount_tx;
		IF current_balance_atual + limit < 0 THEN
			RETURN (0, -1);
		END IF;
	ELSE
		current_balance_atual := current_balance + amount_tx;
	END IF;		
	
	UPDATE clientes c
	SET
		current_balance = current_balance_atual
	WHERE 
		c.id = cliente_id_tx;

	INSERT INTO 
		transactions (cliente_id, amount, kind, description)
	VALUES (cliente_id_tx, amount_tx, kind_tx, description_tx);

	RETURN (current_balance_atual, limit);
END;$$
LANGUAGE plpgsql;