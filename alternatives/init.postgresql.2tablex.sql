CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	current_balance INTEGER NOT NULL DEFAULT 0,
    exrato jsonb NOT NULL DEFAULT '[]'::jsonb
);

INSERT INTO clientes(id, balance) VALUES 
    (1,'[]'), 
    (2,'[]'), 
    (3,'[]'), 
    (4,'[]'), 
    (5,'[]'); 

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('clientes');
SELECT pg_prewarm('transactions');

CREATE TYPE json_result AS (
  status_code INT,
  body json
);

CREATE OR REPLACE FUNCTION proc_transacao(p_shard INT, p_cliente_id INT, p_amount INT, p_kind CHAR, p_description CHAR(10))
RETURNS json_result as $$
DECLARE
    diff INT;
    v_current_balance INT;
    n_current_balance INT;
    v_limit INT;
    result json_result;
BEGIN
    v_limit := CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1
    END;

    SELECT current_balance 
        INTO v_current_balance
        FROM clientes
        WHERE id = p_cliente_id
        FOR UPDATE;

    IF p_kind = 'd' THEN
        n_current_balance := v_current_balance - p_amount;
        IF (n_current_balance < (-1 * v_limit)) THEN
            result.body := '{"erro": "Saldo insuficiente"}';
            result.status_code := 422;
            RETURN result;
        END IF;
    ELSE
      n_current_balance := v_current_balance + p_amount;
    END IF;
    
    INSERT INTO transactions 
                     (cliente_id,   amount,   kind,   description,      submitted_at)
            VALUES (p_cliente_id, p_amount, p_kind, p_description, now());

    UPDATE clientes 
    SET current_balance = n_current_balance,
        balance = (SELECT json_build_object(
                'current_balance', json_build_object(
                    'total', n_current_balance,
                    'date_balance', TO_CHAR(now(), 'YYYY-MM-DD HH:MI:SS.US'),
                    'limit', v_limit
                ),
                'recent_transactions', COALESCE((
                    SELECT json_agg(row_to_json(t)) FROM (
                        SELECT amount, kind, description
                        FROM transactions
                        WHERE cliente_id = p_cliente_id
                        ORDER BY submitted_at DESC
                        LIMIT 10
                    ) t
                ), '[]')
            ))
        WHERE id = p_cliente_id;


    SELECT json_build_object(
        'current_balance', n_current_balance,
        'limit', v_limit
    ) into result.body;
    result.status_code := 200;
    RETURN result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION proc_balance(p_cliente_id int)
RETURNS json_result AS $$
DECLARE
    result json_result;
BEGIN
    SELECT 200, balance 
        FROM clientes
        WHERE id = p_cliente_id
        INTO result.status_code, result.body;
    RETURN result;
END;
$$ LANGUAGE plpgsql;
