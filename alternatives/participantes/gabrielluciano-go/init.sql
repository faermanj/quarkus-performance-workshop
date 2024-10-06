DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS transactions;

CREATE UNLOGGED TABLE IF NOT EXISTS clientes (
    id INTEGER PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    amount INTEGER NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX ON transactions (cliente_id, submitted_at DESC);

INSERT INTO clientes
    (id, limit, current_balance)
VALUES
    (1, 100000,     0),
    (2, 80000,      0),
    (3, 1000000,    0),
    (4, 10000000,   0),
    (5, 500000,     0);

CREATE TYPE transacao_result AS (new_current_balance INT, limit INT); 

CREATE OR REPLACE FUNCTION transacao(id INT, amount INT, kind VARCHAR, description VARCHAR)
RETURNS transacao_result AS $$
DECLARE
  current_balance INTEGER;
  limit INTEGER;
  new_current_balance INTEGER;
BEGIN
  SELECT c.current_balance, c.limit INTO current_balance, limit
  FROM clientes c
  WHERE c.id = transacao.id FOR UPDATE;

  IF kind = 'd' THEN
    new_current_balance := current_balance - amount;
    IF new_current_balance + limit < 0 THEN
      RETURN (0, -1);
    END IF;
  ELSE
    new_current_balance := current_balance + amount;
  END IF;

  UPDATE clientes c SET current_balance = new_current_balance WHERE c.id = transacao.id;

  INSERT INTO transactions (cliente_id, kind, amount, description, submitted_at)
  VALUES (id, kind, amount, description, CURRENT_TIMESTAMP);

  RETURN (new_current_balance, limit);
END;
$$ LANGUAGE plpgsql;
