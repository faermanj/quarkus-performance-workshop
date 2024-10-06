CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL
);

CREATE INDEX idx_cliente_id_trasacoes ON transactions (cliente_id);
CREATE INDEX idx_cliente_id_clientes ON clientes (cliente_id);

DO $$
BEGIN
	INSERT INTO clientes (cliente_id, limit, current_balance)
	VALUES (1,   1000 * 100, 0),
		   (2,    800 * 100, 0),
		   (3,  10000 * 100, 0),
		   (4, 100000 * 100, 0),
		   (5,   5000 * 100, 0);
END;
$$;