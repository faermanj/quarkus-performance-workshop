CREATE TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY,
    nome TEXT NOT NULL,
    limit INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind TEXT NOT NULL,
    description TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE IF NOT EXISTS current_balances (
    id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE INDEX id_index ON clientes (id);
CREATE INDEX id_cliente_transactions_index ON transactions (cliente_id);
CREATE INDEX id_cliente_current_balances_index ON current_balances (cliente_id);

INSERT INTO clientes (nome, limit)
	VALUES
		('ze da manga', 1000 * 100),
		('vai neymar', 800 * 100),
		('loteria', 10000 * 100),
		('nossa', 100000 * 100),
		('o que? como?', 5000 * 100);
	
INSERT INTO current_balances (cliente_id, amount)
    SELECT id, 0 FROM clientes;
