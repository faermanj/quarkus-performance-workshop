SET check_function_bodies = false;
SET idle_in_transaction_session_timeout = 0;
SET lock_timeout = 0;
SET statement_timeout = 0;

CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    amount INTEGER NOT NULL,
    kind VARCHAR(1) NOT NULL,
    submitted_at TIMESTAMP NOT NULL,
    description VARCHAR(255)
);

CREATE INDEX idx_cliente_id_data ON transactions (cliente_id, submitted_at DESC);

INSERT INTO clientes (nome, limit) VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
