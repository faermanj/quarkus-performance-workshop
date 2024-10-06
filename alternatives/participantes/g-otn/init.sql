CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE UNLOGGED TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	CONSTRAINT fk_clientes_current_balances_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('Cliente 1', 1000 * 100),
		('Cliente 2', 800 * 100),
		('Cliente 3', 10000 * 100),
		('Cliente 4', 100000 * 100),
		('Cliente 5', 5000 * 100);
	
	INSERT INTO current_balances (cliente_id, amount)
		SELECT id, 0 FROM clientes;
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
		COALESCE(s.amount, 0)
	INTO
		limit_atual,
		current_balance_atual
	FROM clientes c
		LEFT JOIN current_balances s
			ON c.id = s.cliente_id
	WHERE c.id = cliente_id_tx;

	IF current_balance_atual - amount_tx >= limit_atual * -1 THEN
		INSERT INTO transactions
			VALUES(DEFAULT, cliente_id_tx, amount_tx, 'd', description_tx, NOW());
		
		UPDATE current_balances
		SET amount = amount - amount_tx
		WHERE cliente_id = cliente_id_tx;

		RETURN QUERY
			SELECT
				amount,
				FALSE,
				'ok'::VARCHAR(20)
			FROM current_balances
			WHERE cliente_id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT
				amount,
				TRUE,
				'current_balance insuficente'::VARCHAR(20)
			FROM current_balances
			WHERE cliente_id = cliente_id_tx;
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

	INSERT INTO transactions
		VALUES(DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

	RETURN QUERY
		UPDATE current_balances
		SET amount = amount + amount_tx
		WHERE cliente_id = cliente_id_tx
		RETURNING amount, FALSE, 'ok'::VARCHAR(20);
END;
$$;
