CREATE TABLE IF NOT EXISTS clientes (
  id INTEGER,
  limit INTEGER,
  current_balance INTEGER
);

CREATE TABLE IF NOT EXISTS transactions (
  amount INTEGER,
  kind TEXT,
  description TEXT,
  momento TIMESTAMPTZ DEFAULT NOW(),
  id INTEGER
);

INSERT INTO clientes (id, limit, current_balance)
VALUES 
  (1, 100000, 0),
  (2, 80000, 0),
  (3, 1000000, 0),
  (4, 10000000, 0),
  (5, 500000, 0)
;