CREATE UNLOGGED TABLE clientes (
    id BIGINT PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    amount INTEGER NOT NULL,
    cliente_id BIGINT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP,
    CONSTRAINT fk_cliente_transactions_id
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE INDEX idx_clientes_id ON clientes (id) INCLUDE (limit, current_balance);
CREATE INDEX idx_transactions_clientes_id ON transactions (cliente_id);
CREATE INDEX idx_transactions_clientes_id_realizda_em ON transactions (cliente_id, submitted_at DESC);

DO $$
BEGIN
    INSERT INTO clientes (id, limit)
    VALUES (1, 1000 * 100), (2, 800 * 100), (3, 10000 * 100), (4, 100000 * 100), (5, 5000 * 100);
END;
$$;
