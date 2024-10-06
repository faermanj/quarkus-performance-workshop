DROP TABLE IF EXISTS transactions;
DROP TYPE IF EXISTS transaction_type;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX customers_id_idx ON customers (id);

/* Credit and Debit */
CREATE TYPE transaction_type AS ENUM ('c', 'd');

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  kind transaction_type NOT NULL,
  customer_id INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  submitted_at TIMESTAMP NOT NULL,
  description TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

CREATE INDEX transactions_customer_id_submitted_at_idx ON transactions (customer_id, submitted_at DESC);

BEGIN;

INSERT INTO customers (nome, limit)
VALUES
  ('Isaac Newton', 1000 * 100),
  ('Marie Curie', 800 * 100),
  ('Ada Lovelace', 10000 * 100),
  ('Nikola Tesla', 100000 * 100),
  ('Albert Einstein', 5000 * 100);
  
COMMIT; 