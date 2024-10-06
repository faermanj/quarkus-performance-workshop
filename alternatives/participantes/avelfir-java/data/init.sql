CREATE TABLE IF NOT EXISTS clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
    limit INT DEFAULT 0 NOT NULL,
    current_balance INT DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
	id SERIAL PRIMARY KEY,
    id_cliente INT,
    amount INT DEFAULT 0 NOT NULL,
	kind int NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL,
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);


DO $$
BEGIN
INSERT INTO clientes (nome, limit)
VALUES
    ('diablo', 1000 * 100),
    ('baldurs gate', 800 * 100),
    ('world of warcraft', 10000 * 100),
    ('pokemon', 100000 * 100),
    ('magic', 5000 * 100);
END;
$$;