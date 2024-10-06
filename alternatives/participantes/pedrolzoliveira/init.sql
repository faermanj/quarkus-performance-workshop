
CREATE TYPE kind_transacao AS ENUM (
  'c',
  'd'
);

CREATE TABLE members (
  id SERIAL PRIMARY KEY,
  limit INT NOT NULL DEFAULT 0,
  current_balance INT NOT NULL DEFAULT 0 CHECK (current_balance >= limit * -1)
);

CREATE TABLE transactions (
  cliente_id INT REFERENCES members (id),
  amount INT NOT NULL,
  description VARCHAR(10) NOT NULL CHECK (LENGTH(description) >= 1),
  kind kind_transacao NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX transacao_submitted_at_idx ON transactions (submitted_at);

CREATE OR REPLACE FUNCTION create_transacao (cliente_id int, amount int, kind kind_transacao, description varchar(10))
    RETURNS TABLE (cliente_current_balance int, cliente_limit int)
    AS $$
DECLARE
  ajuste_amount int;
BEGIN
  IF kind = 'd' THEN
    ajuste_amount := amount * - 1;
  ELSE
    ajuste_amount := amount;
  END IF;
  INSERT INTO transactions (cliente_id, amount, kind, description)
    VALUES(cliente_id, amount, kind::kind_transacao, description);
  RETURN QUERY
  UPDATE
    members
  SET
    current_balance = current_balance + ajuste_amount
  WHERE
    id = cliente_id
  RETURNING
    current_balance,
    limit;
END;
$$
LANGUAGE plpgsql;

DO $$
BEGIN
  INSERT INTO members
  (id, limit)
VALUES
  (1, 100000),
  (2, 80000),
  (3, 1000000),
  (4, 10000000),
  (5, 500000);

END;
$$;