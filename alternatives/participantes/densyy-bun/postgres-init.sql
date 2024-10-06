-- Tabelas

CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL
  CONSTRAINT current_balance_limit CHECK (current_balance >= limit * -1)
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	data_registro TIMESTAMP NOT NULL DEFAULT NOW(),
  CONSTRAINT fk_clientes_transactions_id FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Indices

CREATE INDEX idx_clientes_id ON clientes (id);
CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);

-- Funcoes

CREATE OR REPLACE FUNCTION credito(_id INTEGER, amount INTEGER, description VARCHAR)
RETURNS json AS $$
DECLARE
  current_balance_final INTEGER;
  limit_final INTEGER;
BEGIN

  PERFORM pg_advisory_xact_lock(_id);

  INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (_id, amount, 'c', description);
  UPDATE clientes SET current_balance = current_balance + amount WHERE id = _id;

  SELECT current_balance, limit INTO current_balance_final, limit_final FROM clientes WHERE id = _id;
  RETURN json_build_object('current_balance', current_balance_final, 'limit', limit_final);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION debito(_id INTEGER, amount INTEGER, description VARCHAR)
RETURNS json AS $$
DECLARE
  current_balance_antigo INTEGER;
  limit_antigo INTEGER;
  current_balance_final INTEGER;
  limit_final INTEGER;
BEGIN

  PERFORM pg_advisory_xact_lock(_id);

  SELECT current_balance, limit INTO current_balance_antigo, limit_antigo FROM clientes WHERE id = _id;
  IF (current_balance_antigo - amount < limit_antigo * -1) THEN
    RETURN json_build_object('error', true);
  END IF;

  INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (_id, amount, 'd', description);
  UPDATE clientes SET current_balance = current_balance - amount WHERE id = _id;

  SELECT current_balance, limit INTO current_balance_final, limit_final FROM clientes WHERE id = _id;
  RETURN json_build_object('current_balance', current_balance_final, 'limit', limit_final);

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION historico(_id INTEGER)
RETURNS json AS $$
DECLARE
  cliente_info json;
  transactions_info json;
BEGIN

  PERFORM pg_advisory_xact_lock(_id);

  SELECT row_to_json(t) INTO cliente_info FROM (
    SELECT limit, current_balance FROM clientes WHERE id = _id
  ) t;

  SELECT json_agg(row_to_json(t)) INTO transactions_info FROM (
    SELECT amount, kind, description, data_registro FROM transactions WHERE cliente_id = _id ORDER BY data_registro DESC LIMIT 10
  ) t;

  RETURN json_build_object('cliente', cliente_info, 'transactions', transactions_info);

END;
$$ LANGUAGE plpgsql;

-- Dados iniciais

DO $$
BEGIN
	INSERT INTO clientes (id, limit, current_balance)
	VALUES
    (1, 1000 * 100, 0),
    (2, 800 * 100, 0),
    (3, 10000 * 100, 0),
    (4, 100000 * 100, 0),
    (5, 5000 * 100, 0);
END;
$$;

-- Tune Postgres

ALTER SYSTEM SET max_connections = '200';
ALTER SYSTEM SET shared_buffers = '72960kB';
ALTER SYSTEM SET effective_cache_size = '218880kB';
ALTER SYSTEM SET maintenance_work_mem = '18240kB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '2188kB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '1.1';
ALTER SYSTEM SET effective_io_concurrency = '200';
ALTER SYSTEM SET work_mem = '182kB';
ALTER SYSTEM SET huge_pages = 'off';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '4GB';
