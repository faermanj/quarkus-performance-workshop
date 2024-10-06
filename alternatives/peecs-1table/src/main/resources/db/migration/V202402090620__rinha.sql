CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(255) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO clientes (nome, limit) VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);
