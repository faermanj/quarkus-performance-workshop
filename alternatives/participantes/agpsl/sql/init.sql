CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
  current_balance INTEGER NOT NULL,
	limit INTEGER NOT NULL,
  CONSTRAINT ck_current_balance CHECK ( clientes.current_balance > (clientes.limit * -1))
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

INSERT INTO clientes (nome, current_balance, limit)
VALUES
  ('Cliente 01', 0, 1000 * 100),
  ('Cliente 02', 0, 800 * 100),
  ('Cliente 03', 0, 10000 * 100),
  ('Cliente 04', 0, 100000 * 100),
  ('Cliente 05', 0, 5000 * 100);
