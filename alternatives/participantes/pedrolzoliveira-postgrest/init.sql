CREATE SCHEMA api;
CREATE ROLE anon NOLOGIN;
GRANT USAGE ON SCHEMA api TO anon;

CREATE UNLOGGED TABLE api.members (
  id SERIAL PRIMARY KEY,
  limit INT NOT NULL DEFAULT 0,
  current_balance INT NOT NULL DEFAULT 0 CHECK (current_balance >= -limit)
);

CREATE UNLOGGED TABLE api.transactions (
  cliente_id INT REFERENCES api.members (id),
  amount INT NOT NULL,
  description VARCHAR(10) NOT NULL,
  kind CHAR(1) NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX transacao_submitted_at_idx ON api.transactions (submitted_at);

CREATE OR REPLACE FUNCTION api.create_transacao (cliente_id int, amount int, kind char(1), description varchar(10))
RETURNS JSON
AS $$
DECLARE
  ajuste_amount int;
  novo_current_balance int;
  novo_limit int;
  json_result JSON;
BEGIN
  IF kind = 'd' THEN
    ajuste_amount := -amount;
  ELSE
    ajuste_amount := amount;
  END IF;

  INSERT INTO api.transactions (cliente_id, amount, kind, description)
    VALUES (cliente_id, amount, kind, description);

  UPDATE api.members
  SET current_balance = current_balance + ajuste_amount
  WHERE id = cliente_id
  RETURNING current_balance, limit INTO novo_current_balance, novo_limit;

  json_result := json_build_object(
    'current_balance', novo_current_balance,
    'limit', novo_limit
  );

  RETURN json_result;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE sqlstate 'PGRST' USING
        message = '{"code":"422","message":"limit de current_balance excedido"}',
        detail = '{"status":422,"headers":{}}';


END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.balance(p_cliente_id int)
RETURNS JSON
AS $$
DECLARE
  result JSON;
BEGIN
  WITH recent_transactions AS (
    SELECT amount, kind, description, submitted_at
    FROM api.transactions t
    WHERE cliente_id = p_cliente_id
    ORDER BY submitted_at DESC
    LIMIT 10
  ),
  current_balance AS (
    SELECT current_balance AS total, NOW() AS date_balance, limit
    FROM api.members c
    WHERE id = p_cliente_id
  )
  SELECT json_build_object(
    'current_balance', (SELECT row_to_json(s) FROM current_balance s),
    'recent_transactions', (SELECT COALESCE(json_agg(u), '[]') FROM recent_transactions u)
  ) INTO result;
  
  RETURN result;
END;
$$
LANGUAGE PLPGSQL;

GRANT SELECT, UPDATE ON api.members TO anon;
GRANT SELECT, INSERT ON api.transactions TO anon;

DO $$
BEGIN
  INSERT INTO api.members
  (id, limit)
VALUES
  (1, 100000),
  (2, 80000),
  (3, 1000000),
  (4, 10000000),
  (5, 500000);

END;
$$;