-- A table for storing/updating all client's data.
-- A single entry per client.
CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0 CHECK (current_balance >= -limit)
);

-- A table for storing the transactions executed by all clients.
-- Multiple entries for each client.
CREATE TABLE transactions (
    id INTEGER REFERENCES members(id),
    amount INTEGER NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO members (limit) 
VALUES 
    (100000),
    (80000),
    (1000000),
    (10000000),
    (500000);