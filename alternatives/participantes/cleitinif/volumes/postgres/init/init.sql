CREATE TABLE clientes (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_transactions_clientes_id FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO
	clientes (id, limit)
VALUES
	(1, 100000),
	(2, 80000),
	(3, 1000000),
	(4, 10000000),
	(5, 500000);