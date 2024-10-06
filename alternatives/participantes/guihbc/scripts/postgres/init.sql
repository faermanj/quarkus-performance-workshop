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

DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('Guilherme', 1000 * 100),
		('Yasmim', 800 * 100),
		('Jose', 10000 * 100),
		('Maria', 100000 * 100),
		('Aparecida', 5000 * 100);
	
	INSERT INTO current_balances (cliente_id, amount)
		SELECT id, 0 FROM clientes;
END;
$$;

CREATE INDEX idx_current_balances_amount ON current_balances (amount);
