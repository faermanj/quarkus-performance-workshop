-- Create the clients table
CREATE UNLOGGED TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
    );

-- Create the transactions table
CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    amount INTEGER NOT NULL,
    cliente_id INTEGER NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create an index on cliente_id for performance optimization
CREATE INDEX idx_cliente_id ON transactions(cliente_id);

-- Insert initial data into clients
INSERT INTO clients (limit, current_balance)
VALUES
    (100000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);
