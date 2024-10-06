CREATE UNLOGGED TABLE members (
    id INTEGER PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0,
    description_current_balance_atual VARCHAR(10)
);

CREATE UNLOGGED TABLE transactions (
    id INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CLOCK_TIMESTAMP()
);

ALTER TABLE
    transactions
ADD
    CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES members (id);

CREATE INDEX IF NOT EXISTS idx_members_id ON members (id) INCLUDE(current_balance, limit);

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_transactions ON transactions (id, cliente_id);

CREATE INDEX IF NOT EXISTS idx_transactions_cliente_id_submitted_at_desc ON transactions (cliente_id, submitted_at DESC);