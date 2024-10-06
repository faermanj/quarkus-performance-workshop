CREATE DATABASE rinha2024q1;

\c rinha2024q1;

CREATE TABLE customers (
    id CHAR(1) PRIMARY KEY,
    limit INTEGER,
    current_balance integer
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    customer_id char(1) REFERENCES customers(id),
    amount INTEGER,
    kind CHAR(1),
    description CHAR(10),
    submitted_at TIMESTAMP,
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE INDEX idx_customer_id_submitted_at ON transactions(customer_id, submitted_at);

INSERT INTO customers(id, limit, current_balance) VALUES ('1', 100000, 0);
INSERT INTO customers(id, limit, current_balance) VALUES ('2', 80000, 0);
INSERT INTO customers(id, limit, current_balance) VALUES ('3', 1000000, 0);
INSERT INTO customers(id, limit, current_balance) VALUES ('4', 10000000, 0);
INSERT INTO customers(id, limit, current_balance) VALUES ('5', 500000, 0);

ALTER SYSTEM SET max_connections = 500;