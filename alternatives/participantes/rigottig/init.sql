CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    limit INT NOT NULL,
    current_balance INT NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL CHECK (kind IN ('c', 'd')),
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

DO $$
BEGIN
INSERT INTO
    members (id, limit, current_balance)
VALUES
    (1, 1000 * 100, 0),
    (2, 800 * 100, 0),
    (3, 10000 * 100, 0),
    (4, 100000 * 100, 0),
    (5, 5000 * 100, 0) ON CONFLICT (id) DO NOTHING;
END;
$$