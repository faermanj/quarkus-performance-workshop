DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS transactions;

CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
    limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX ix_transactions_cliente_id ON transactions (cliente_id);

INSERT INTO members (id, limit, current_balance) VALUES
(1, 1000 * 100, 0),
(2, 800 * 100, 0),
(3, 10000 * 100, 0),
(4, 100000 * 100, 0),
(5, 5000 * 100, 0);

---------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	deu_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql AS
$$
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);

	INSERT INTO transactions VALUES
    (DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

	RETURN QUERY
		UPDATE members
		SET current_balance = current_balance + amount_tx
		WHERE id = cliente_id_tx
		RETURNING current_balance, FALSE, 'ok'::VARCHAR(20);
END;
$$;

---------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	deu_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql AS
$$
DECLARE
	current_balance_atual int;
	limit_atual int;
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);

	SELECT limit, COALESCE(current_balance, 0)
	INTO limit_atual, current_balance_atual
	FROM members
	WHERE id = cliente_id_tx;

	IF current_balance_atual - amount_tx >= limit_atual * -1 THEN
		INSERT INTO transactions VALUES
        (DEFAULT, cliente_id_tx, amount_tx, 'd', description_tx, NOW());

		UPDATE members
		SET current_balance = current_balance - amount_tx
		WHERE id = cliente_id_tx;

		RETURN QUERY
			SELECT current_balance, FALSE, 'ok'::VARCHAR(20)
			FROM members
			WHERE id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT current_balance, TRUE, 'not enough cash'::VARCHAR(20)
			FROM members
			WHERE id = cliente_id_tx;
	END IF;
END;
$$;
