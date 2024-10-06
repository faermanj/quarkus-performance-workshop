-- rinha.schema.sql

-- Tabela de clientes
CREATE TABLE IF NOT EXISTS clientes (
  	id INTEGER PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
);

-- Tabela de transações
CREATE TABLE IF NOT EXISTS transactions (
  	id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind TEXT NOT NULL,
    description TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Inserções iniciais
INSERT INTO clientes (id, limit, current_balance) VALUES
(1, 1000 * 100, 0),
(2, 800 * 100, 0),
(3, 10000 * 100, 0),
(4, 100000 * 100, 0),
(5, 5000 * 100, 0)
