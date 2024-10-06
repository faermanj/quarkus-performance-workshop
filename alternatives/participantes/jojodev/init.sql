CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    limit INT NOT NULL
);

CREATE UNLOGGED TABLE current_balances(
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    amount INT NOT NULL,
    kind CHAR(1) CHECK (kind IN ('c', 'd')) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    cliente_id INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

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