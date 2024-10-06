CREATE UNLOGGED TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_limit CHECK (-current_balance <= limit)
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_transactions_submitted_at ON transactions(submitted_at DESC, user_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);

INSERT INTO users(id, limit)
VALUES 
    (1, 100000),
    (2, 80000),
    (3, 1000000),
    (4, 10000000),
    (5, 500000)
