CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
    id SERIAL PRIMARY KEY NOT NULL,
    limit INTEGER,
    current_balance INTEGER
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacao (
    id SERIAL PRIMARY KEY NOT NULL,
    kind CHAR(1),
    description VARCHAR(10),
    amount INTEGER,
    cliente_id INTEGER NOT NULL,
    submitted_at VARCHAR(70)
);

CREATE INDEX IF NOT EXISTS idx_cliente_id ON transacao (cliente_id);

CREATE INDEX IF NOT EXISTS idx_submitted_at ON transacao (submitted_at);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;

SELECT pg_prewarm('cliente');

SELECT pg_prewarm('transacao');

INSERT INTO cliente (limit, current_balance)
VALUES
    (100000, 0),
    ( 80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);