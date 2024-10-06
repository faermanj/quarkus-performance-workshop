CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    limit INT,
    current_balance INT
);

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER,
    kind CHAR(1),
    description VARCHAR(10),
    submitted_at VARCHAR(27)
);

CREATE INDEX IF NOT EXISTS idx_cliente_id ON transactions(cliente_id);
CREATE INDEX IF NOT EXISTS idx_submitted_at ON transactions(submitted_at);

INSERT INTO clientes (limit, current_balance)
VALUES
    (  100000, 0),
    (   80000, 0),
    ( 1000000, 0),
    (10000000, 0),
    (  500000, 0);