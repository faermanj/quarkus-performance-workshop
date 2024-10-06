
CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNLOGGED TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	limit INTEGER NOT NULL,
	amount INTEGER NOT NULL
);

CREATE INDEX ids_transactions_ids_cliente_id ON transactions (cliente_id);
CREATE INDEX ids_current_balances_ids_cliente_id ON current_balances (cliente_id);

DO $$
BEGIN
	INSERT INTO current_balances (cliente_id, limit, amount)
	VALUES (1,   1000 * 100, 0),
		   (2,    800 * 100, 0),
		   (3,  10000 * 100, 0),
		   (4, 100000 * 100, 0),
		   (5,   5000 * 100, 0);
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
		s.limit,
		COALESCE(s.amount, 0)
	INTO
		limit_atual,
		current_balance_atual
	FROM current_balances s
	WHERE s.cliente_id = cliente_id_tx;

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
