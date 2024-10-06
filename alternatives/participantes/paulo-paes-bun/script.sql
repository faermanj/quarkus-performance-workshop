CREATE TABLE members(
  id INT PRIMARY KEY,
  limit DECIMAL(10,0),
  current_balance DECIMAL(10,0)
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  cliente_id INT,
  amount DECIMAL(10,0),
  kind char(1),
  description varchar(10),
  submitted_at timestamp default now(),
  FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX idx_transactions_members_id ON transactions (cliente_id);
CREATE INDEX idx_transactions_submitted_at ON transactions (submitted_at);


INSERT INTO members VALUES (1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);
