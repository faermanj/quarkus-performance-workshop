CREATE UNLOGGED TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES members (id),
    amount INTEGER NOT NULL,
	submitted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
	description VARCHAR(10) NOT NULL,
	kind CHAR(1) NOT NULL
);

CREATE INDEX transacao_order_idx ON transactions USING btree (cliente_id, id DESC);

INSERT INTO members (limit, current_balance) VALUES
    (1000 * 100, 0),
    (800 * 100, 0),
    (10000 * 100, 0),
    ( 100000 * 100, 0),
    (5000 * 100, 0);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;

-- Carregar a tabela members
SELECT pg_prewarm('members');

-- Carregar a tabela transactions
SELECT pg_prewarm('transactions');

-- Carregar o índice transacao_order_idx
SELECT pg_prewarm('transacao_order_idx');