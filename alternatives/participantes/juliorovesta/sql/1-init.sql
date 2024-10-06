DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clientes;

CREATE UNLOGGED TABLE clientes (
	cliente_id INTEGER PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL,
	current_balance_atualizado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNLOGGED TABLE transactions (
	transacao_id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	current_balance INTEGER NOT NULL,
	CONSTRAINT fk__clientes__transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

CREATE INDEX ix__transactions__cliente_cliente ON transactions (cliente_id, submitted_at DESC);

DO $$
BEGIN
	INSERT INTO clientes (cliente_id, nome, limit, current_balance)
	VALUES
		(1, 'o barato sai caro', 1000 * 100, 0),
		(2, 'zan corp ltda', 800 * 100, 0),
		(3, 'les cruders', 10000 * 100, 0),
		(4, 'padaria joia de cocaia', 100000 * 100, 0),
		(5, 'kid mais', 5000 * 100, 0);
END;
$$;
