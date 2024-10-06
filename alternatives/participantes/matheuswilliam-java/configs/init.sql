CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacao (
    cliente_id INTEGER NOT NULL REFERENCES cliente (id),
    amount INTEGER NOT NULL,
	submitted_at TIMESTAMPTZ DEFAULT now() NOT NULL,
	description VARCHAR(10) NOT NULL,
	kind CHAR(1) NOT NULL
);

CREATE INDEX transacao_idx ON transacao USING btree (cliente_id, submitted_at);

INSERT INTO cliente (limit, current_balance) VALUES
    (1000 * 100, 0),
    (800 * 100, 0),
    (10000 * 100, 0),
    ( 100000 * 100, 0),
    (5000 * 100, 0);
