CREATE TABLE IF NOT EXISTS client (
  id SERIAL PRIMARY KEY,
  limit INT NOT NULL,
  current_balance INT NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  client_id INT REFERENCES client(id),
  amount INT NOT NULL,
  kind VARCHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO client (limit, current_balance) 
VALUES 
  (100000, 0),
  (80000, 0),
  (1000000, 0),
  (10000000, 0),
  (500000, 0);