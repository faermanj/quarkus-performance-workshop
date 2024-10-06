CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

DO $$
BEGIN
	INSERT INTO members (nome, limit, current_balance)
	VALUES
		('o barato sai caro', 1000 * 100, 0),
		('zan corp ltda', 800 * 100, 0),
		('les cruders', 10000 * 100, 0),
		('padaria joia de cocaia', 100000 * 100, 0),
		('kid mais', 5000 * 100, 0);
END;
$$;

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	limit INT,
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
		members.limit,
		COALESCE(current_balance, 0)
	INTO
		limit_atual,
		current_balance_atual
	FROM members
	WHERE id = cliente_id_tx;

	IF current_balance_atual - amount_tx >= limit_atual * -1 THEN
		INSERT INTO transactions
			VALUES(DEFAULT, cliente_id_tx, amount_tx, 'd', description_tx, NOW());
		
		UPDATE members
		SET current_balance = current_balance - amount_tx
		WHERE id = cliente_id_tx;

		RETURN QUERY
			SELECT
				current_balance,
				members.limit,
				FALSE,
				'ok'::VARCHAR(20)
			FROM members
			WHERE id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT
				current_balance,
				members.limit,
				TRUE,
				'current_balance insuficiente'::VARCHAR(20)
			FROM members
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
	limit INT,
	possui_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);

	INSERT INTO transactions
		VALUES(DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

	RETURN QUERY
		UPDATE members
		SET current_balance = current_balance + amount_tx
		WHERE id = cliente_id_tx
		RETURNING current_balance, members.limit, FALSE, 'ok'::VARCHAR(20);
END;
$$;