CREATE UNLOGGED TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    limite INTEGER NOT NULL,
    saldo INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES members (id),
    valor INTEGER NOT NULL,
	realizada_em TIMESTAMPTZ DEFAULT now() NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	tipo CHAR(1) NOT NULL
);

CREATE INDEX transacao_order_idx ON transactions USING btree (cliente_id, id DESC);

INSERT INTO members (limite, saldo) VALUES
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