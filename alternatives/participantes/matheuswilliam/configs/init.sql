CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacao (
    cliente_id INTEGER NOT NULL REFERENCES cliente (id),
    amount INTEGER NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	description VARCHAR(10) NOT NULL,
	kind CHAR(1) NOT NULL
);

CREATE INDEX idx_cliente_id ON cliente (id);
CREATE INDEX idx_submitted_at ON transacao (submitted_at);

INSERT INTO cliente (nome, limit) VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
