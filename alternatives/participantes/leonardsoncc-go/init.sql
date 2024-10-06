SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET row_security = off;

CREATE UNLOGGED TABLE IF NOT EXISTS members(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0 NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions(
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES members (id),
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT current_timestamp
);

CREATE INDEX transactions_cliente_id_idx ON transactions (cliente_id, submitted_at DESC);

DO $$
BEGIN
  INSERT INTO members (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END;
$$;
