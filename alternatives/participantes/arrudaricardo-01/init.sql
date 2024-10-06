
CREATE TABLE account (
  id INTEGER PRIMARY KEY,
  current_balance INTEGER NOT NULL,
  limit INTEGER NOT NULL
);
CREATE TABLE account_transaction (
  id SERIAL PRIMARY KEY,
  account_id INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  FOREIGN KEY(account_id) REFERENCES account(id)
);

INSERT INTO account (id, limit, current_balance) VALUES (1, 100000, 0);
INSERT INTO account (id, limit, current_balance) VALUES (2, 80000, 0);
INSERT INTO account (id, limit, current_balance) VALUES (3, 1000000, 0);
INSERT INTO account (id, limit, current_balance) VALUES (4, 10000000, 0);
INSERT INTO account (id, limit, current_balance) VALUES (5, 500000, 0);
