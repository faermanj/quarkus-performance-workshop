CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL,
	amount INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transacao (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	quando TEXT NOT NULL,
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO clientes (limit, amount) VALUES
	(100000, 0),
	(80000, 0),
	(1000000, 0),
	(10000000, 0),
	(500000, 0);