DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS transactions;

CREATE UNLOGGED TABLE clients (
	id SERIAL PRIMARY KEY,
	current_balance INTEGER NOT null default 0,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	constraint fk_clients_transactions_id
		foreign key (cliente_id) references clients(id)
);

CREATE INDEX ids_transactions_ids_cliente_id ON transactions (cliente_id);


DO $$
BEGIN
	INSERT INTO clients (current_balance, limit)
	VALUES
		(0, 1000 * 100),
		(0, 800 * 100),
		(0, 10000 * 100),
		(0, 100000 * 100),
		(0, 5000 * 100);
END;
$$;

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	amount_tx INT8,
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
		limit,
		current_balance
	INTO
		limit_atual,
		current_balance_atual
	FROM clients
	WHERE id  = cliente_id_tx;

	IF current_balance_atual - amount_tx >= limit_atual * -1 THEN
		INSERT INTO transactions
			VALUES(DEFAULT, cliente_id_tx, amount_tx, 'd', description_tx, NOW());
		
		UPDATE clients
		SET current_balance = current_balance - amount_tx
		WHERE id = cliente_id_tx;

		RETURN QUERY
			SELECT
				current_balance,
				FALSE,
				'ok'::VARCHAR(20)
			FROM clients
			where id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT
				current_balance,
				TRUE,
				'current_balance insuficente'::VARCHAR(20)
			FROM clients
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

	INSERT INTO transactions 
		VALUES(DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

	RETURN QUERY
		UPDATE clients
		SET current_balance  = current_balance  + amount_tx
		WHERE id  = cliente_id_tx
		RETURNING current_balance , FALSE, 'ok'::VARCHAR(20);
END;
$$;