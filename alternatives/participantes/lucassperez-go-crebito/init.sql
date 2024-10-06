CREATE TABLE IF NOT EXISTS clientes (
  id SERIAL PRIMARY KEY,
  limit INT NOT NULL,
  current_balance INT NOT NULL DEFAULT 0
);

CREATE TYPE kind_transacao AS ENUM ('c', 'd');

CREATE TABLE IF NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  amount INT NOT NULL CHECK (amount > 0),
  kind kind_transacao NOT NULL,
  description VARCHAR(10) CHECK (LENGTH(description) >= 1),
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cliente_id INT REFERENCES clientes (id) ON DELETE CASCADE
);
