CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
    limit INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    description VARCHAR(10) NOT NULL,
    kind CHAR(1) NOT NULL,
    submitted_at TIMESTAMP NOT NULL,
    id_cliente INTEGER NOT NULL
);

CREATE INDEX idx_transactions_id_cliente ON transactions (id_cliente);

CREATE TYPE criar_transacao_result AS (
  code integer,
  current_balance integer,
  limit integer
);

CREATE FUNCTION criar_transacao(a_id_cliente INTEGER, amount INTEGER, description VARCHAR(10), kind CHAR(1))
RETURNS criar_transacao_result AS $$
DECLARE 
  current_data RECORD;
  result criar_transacao_result;
  copy_amount INTEGER;
BEGIN
  PERFORM pg_advisory_xact_lock(a_id_cliente);
  SELECT * INTO current_data FROM transactions WHERE id_cliente = a_id_cliente order by id desc limit 1;
	
  IF current_data IS NULL THEN
    SELECT -1, -1, -1 INTO result;
    RETURN result;
  END IF;

  IF kind = 'd' THEN
    copy_amount := amount * -1;
  ELSE
    copy_amount := amount;
  END IF;

  IF copy_amount < 0 AND current_data.current_balance + copy_amount < current_data.limit * -1 THEN
    SELECT -2, -2, -2 INTO result;
  ELSE
      INSERT INTO transactions (current_balance, limit, amount, description, kind, submitted_at, id_cliente)
        VALUES (current_data.current_balance + copy_amount, current_data.limit, amount, description, kind, NOW(), a_id_cliente)
        RETURNING 0, current_balance, limit INTO result;
  END IF;

  RETURN result;  
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_balance(a_id_cliente INTEGER)
RETURNS json AS $$
DECLARE
    result json;
    cliente_data RECORD;
BEGIN
    SELECT current_balance, limit INTO cliente_data FROM transactions WHERE id_cliente = a_id_cliente order by id desc limit 1;

    IF cliente_data IS NULL THEN
        SELECT NULL INTO result;
        RETURN result;
    END IF;

    SELECT json_build_object(
        'current_balance', json_build_object(
            'total', cliente_data.current_balance,
            'date_balance', NOW(),
            'limit', cliente_data.limit
        ),
        'recent_transactions', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT amount, kind, description, submitted_at FROM transactions WHERE id_cliente = a_id_cliente ORDER BY id DESC LIMIT 10
            ) t
        ), '[]')
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  INSERT INTO transactions (id_cliente, current_balance, limit, amount, description, kind, submitted_at)
  VALUES
    (1, 0, 1000 * 100, 0, '', 'c', now()),
    (2, 0, 800 * 100, 0, '', 'c', now()),
    (3, 0, 10000 * 100, 0, '', 'c', now()),
    (4, 0, 100000 * 100, 0, '', 'c', now()),
    (5, 0, 5000 * 100, 0, '', 'c', now());
END; $$