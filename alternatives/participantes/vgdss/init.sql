CREATE UNLOGGED TABLE members (
    id SERIAL PRIMARY KEY,
    limit INT NOT NULL,
    current_balance INT NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    cliente_id INT,
    CONSTRAINT fk_cliente_transactions FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX idx_transactions_cliente_id_id_desc ON transactions (cliente_id, id DESC);

INSERT INTO members (id, limit, current_balance) VALUES
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
SELECT pg_prewarm('transactions');
