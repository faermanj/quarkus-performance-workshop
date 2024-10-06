CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL,
    cliente_id INTEGER NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes (id)
);

CREATE INDEX idx_cliente_id_submitted_at ON transactions (cliente_id, submitted_at DESC);

DO $$
BEGIN
  INSERT INTO clientes (id, nome, limit)
  VALUES
    (1, 'o barato sai caro', 100000),
    (2, 'zan corp ltda', 80000),
    (3, 'les cruders', 1000000),
    (4, 'padaria joia de cocaia', 10000000),
    (5, 'kid mais', 500000);
END; $$
