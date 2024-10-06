DROP TABLE IF EXISTS Transaction;

DROP TABLE IF EXISTS Account;

CREATE TABLE Account (
  id SERIAL PRIMARY KEY,
  limit INTEGER NOT NULL DEFAULT 0,
  current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE Transaction (
  id SERIAL PRIMARY KEY,
  account_id INTEGER REFERENCES Account(id),
  amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transaction_accountId_createdAt ON Transaction (account_id, submitted_at DESC);

INSERT INTO Account (id, limit)
VALUES
  (1, 100000),
  (2, 80000),
  (3, 1000000),
  (4, 10000000),
  (5, 500000);