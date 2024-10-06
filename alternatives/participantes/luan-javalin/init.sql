DROP TABLE IF EXISTS current_balances;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clientes;

CREATE UNLOGGED TABLE IF NOT EXISTS clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE UNLOGGED TABLE IF NOT EXISTS current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	CONSTRAINT fk_clientes_current_balances_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);
CREATE INDEX idx_transactions_criado_em ON transactions (submitted_at);

DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);

	INSERT INTO current_balances (cliente_id, amount)
		SELECT id, 0 FROM clientes;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	amount_tx INT,
	current_balance_tx INT,
	kind_tx VARCHAR(2),
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	possui_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql
AS $$
BEGIN
	--PERFORM pg_advisory_xact_lock(cliente_id_tx);

	INSERT INTO transactions
		VALUES(DEFAULT, cliente_id_tx, amount_tx, kind_tx, description_tx, NOW());

	RETURN QUERY
		UPDATE current_balances
		SET amount = current_balance_tx
		WHERE cliente_id = cliente_id_tx
		RETURNING amount, FALSE, 'ok'::VARCHAR(20);
END;
$$;