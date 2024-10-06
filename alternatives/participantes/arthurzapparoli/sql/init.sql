CREATE UNLOGGED TABLE clientes (
	id SMALLSERIAL PRIMARY KEY,
	current_balance INTEGER NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
  id SERIAL PRIMARY KEY,
  cliente_id SMALLINT NOT NULL,
  amount SMALLINT NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT chave_cliente_id FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);

CREATE OR REPLACE FUNCTION debitar(
  param_cliente_id SMALLINT,
  param_amount SMALLINT,
  param_description VARCHAR(10),
  OUT resultado_codigo SMALLINT,
  OUT resultado_current_balance INTEGER,
  OUT resultado_limit INTEGER
)
AS $$
BEGIN
  -- initialize out parameters
  resultado_codigo := 0; -- assume success
  resultado_current_balance := NULL;
  resultado_limit := NULL;

  -- check if the client exists and fetch their balance_limit
  SELECT limit INTO resultado_limit FROM clientes WHERE id = param_cliente_id;

  IF resultado_limit IS NULL THEN
    resultado_codigo := 1; -- client does not exist
    RETURN;
  END IF;

  -- attempt to update the client's balance only if the new balance is within limits
  UPDATE clientes SET current_balance = current_balance - param_amount 
  WHERE id = param_cliente_id AND current_balance - param_amount >= -limit
  RETURNING current_balance INTO resultado_current_balance;

  -- insert the record if the update was successful
  IF NOT FOUND THEN
    resultado_codigo := 2; -- Update failed due to balance constraints.
  ELSE
    INSERT INTO transactions (
      cliente_id,
      amount,
      kind,
      description,
      submitted_at)
    VALUES (
      param_cliente_id,
      param_amount,
      'd',
      param_description,
      NOW()
    );

    resultado_codigo := 0; -- success
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION creditar(
  param_cliente_id SMALLINT,
  param_amount SMALLINT,
  param_description VARCHAR(10),
  OUT resultado_codigo SMALLINT,
  OUT resultado_current_balance INTEGER,
  OUT resultado_limit INTEGER
)
AS $$
BEGIN
  -- initialize out parameters
  resultado_codigo := 0; -- assume success
  resultado_current_balance := NULL;
  resultado_limit := NULL;

  -- check if the client exists and fetch their balance_limit
  SELECT limit INTO resultado_limit FROM clientes WHERE id = param_cliente_id;

  IF resultado_limit IS NULL THEN
    resultado_codigo := 1; -- client does not exist
    RETURN;
  END IF;

  UPDATE clientes SET current_balance = current_balance + param_amount 
  WHERE id = param_cliente_id
  RETURNING current_balance INTO resultado_current_balance;

  INSERT INTO transactions (
    cliente_id,
    amount,
    kind,
    description,
    submitted_at)
  VALUES (
    param_cliente_id,
    param_amount,
    'c',
    param_description,
    NOW()
  );

  resultado_codigo := 0; -- success
END;
$$ LANGUAGE plpgsql;

BEGIN;
  INSERT INTO clientes (id, current_balance, limit) VALUES (1, 0, 100000);
  INSERT INTO clientes (id, current_balance, limit) VALUES (2, 0, 80000);
  INSERT INTO clientes (id, current_balance, limit) VALUES (3, 0, 1000000);
  INSERT INTO clientes (id, current_balance, limit) VALUES (4, 0, 10000000);
  INSERT INTO clientes (id, current_balance, limit) VALUES (5, 0, 500000);
END;
