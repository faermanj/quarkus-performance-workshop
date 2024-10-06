CREATE UNLOGGED TABLE clientes (
  id INTEGER PRIMARY KEY,
  current_balance INTEGER NOT NULL DEFAULT 0);

CREATE UNLOGGED TABLE transactions (
  id SERIAL PRIMARY KEY,
  cliente_id INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL DEFAULT 'd',
  description VARCHAR(10) NOT NULL);

CREATE INDEX transactions_cliente_id ON transactions (cliente_id);

CREATE OR REPLACE FUNCTION crebitar_d(
  cliente_id_input INTEGER,
  amount_input INTEGER,
  description_input VARCHAR(10),
  limit INTEGER) 
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  atual INTEGER;
BEGIN
  PERFORM pg_advisory_xact_lock(cliente_id_input);
  SELECT c.current_balance
  INTO atual
  FROM clientes c
  WHERE c.id = cliente_id_input;

  IF atual - amount_input < limit THEN
    RETURN NULL;
  END IF;

  atual := atual - amount_input;
  
  INSERT INTO transactions (cliente_id, amount, description) VALUES (cliente_id_input, amount_input, description_input);
  UPDATE clientes SET current_balance = atual WHERE id = cliente_id_input;
  
  RETURN atual;
END;
$$;

CREATE OR REPLACE FUNCTION crebitar_c(
  cliente_id_input INTEGER,
  amount_input INTEGER,
  description_input VARCHAR(10),
  limit INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
  atual INTEGER;
BEGIN
  PERFORM pg_advisory_xact_lock(cliente_id_input);

  INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (cliente_id_input, amount_input, 'c', description_input);
  UPDATE clientes SET current_balance = current_balance + amount_input WHERE id = cliente_id_input RETURNING current_balance INTO atual;

  RETURN atual;
END;
$$;

CREATE OR REPLACE FUNCTION balance(cliente_id_input INTEGER)
  RETURNS TABLE (amount_out INTEGER, kind_out CHAR(1), description_out VARCHAR(10)) AS
$body$
BEGIN
  RETURN QUERY (
    (SELECT c.current_balance, 'x' AS kind, '' AS description
     FROM clientes AS c
     WHERE c.id=$1)
    UNION ALL
    (SELECT t.amount, t.kind, t.description
     FROM transactions AS t
     WHERE t.cliente_id=$1
     ORDER BY id DESC
     LIMIT 10)
  );
END;
$body$
LANGUAGE plpgsql
  ROWS 11;