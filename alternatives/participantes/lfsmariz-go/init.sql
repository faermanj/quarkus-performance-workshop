SET client_encoding = 'UTF8';
SET client_min_messages = warning;
SET row_security = off;

CREATE UNLOGGED TABLE IF NOT EXISTS clientes(
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0 NOT NULL
    CONSTRAINT check_limit CHECK (current_balance >= -limit)
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions(
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes (id),
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT current_timestamp
);

CREATE OR REPLACE FUNCTION add_transaction(
  id_client INTEGER,
  type_op CHAR(1),
  value_op INTEGER,
  desc_op VARCHAR(10)
)
RETURNS TABLE (
    lim INTEGER,
    bal INTEGER
) AS $$

DECLARE
  limit_value INTEGER;
  balance_value INTEGER;
BEGIN
-- Add Logic for update value
  SELECT limit, current_balance INTO limit_value, balance_value FROM clientes WHERE id = id_client;
  IF type_op = 'd' THEN
    IF (balance_value - value_op) * -1 > limit_value THEN
      RAISE EXCEPTION 'invalid';
    ELSE
      UPDATE clientes SET current_balance = current_balance - value_op WHERE id = id_client;
    END IF;
  ELSIF type_op = 'c' THEN
    UPDATE clientes SET current_balance = current_balance + value_op WHERE id = id_client;
  END IF;
-- Insert on transaction
  INSERT INTO transactions (cliente_id, amount, kind, description)
  VALUES (id_client, value_op, type_op, desc_op);

  RETURN QUERY
  SELECT limit, current_balance FROM clientes WHERE id = id_client;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  INSERT INTO clientes (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END;
$$;