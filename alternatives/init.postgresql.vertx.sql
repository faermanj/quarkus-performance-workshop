CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	current_balance INTEGER NOT NULL DEFAULT 0,
    balance TEXT
);
    
CREATE UNLOGGED TABLE transactions (
	id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL);

CREATE INDEX idx_cliente_id ON transactions (cliente_id);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
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
    v_limit INT;
    result json_result;
    v_balance TEXT;
BEGIN
    -- SELECT limit_cliente(p_cliente_id) INTO v_limit;
    v_limit := CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1 -- Valor padrão caso o id do cliente não esteja entre 1 e 5
    END;

    SELECT current_balance 
        INTO v_current_balance
        FROM members
        WHERE id = p_cliente_id
        FOR UPDATE;

    IF p_kind = 'd' AND ((v_current_balance - p_amount) < (-1 * v_limit)) THEN
            result.body := 'LIMITE_INDISPONIVEL';
            result.status_code := 422;
            RETURN result;
    END IF;
    
    INSERT INTO transactions 
                     (cliente_id,   amount,   kind,   description,      submitted_at)
            VALUES (p_cliente_id, p_amount, p_kind, p_description, now());

    UPDATE members 
    SET current_balance = CASE 
                    WHEN p_kind = 'c' THEN current_balance + p_amount
                    WHEN p_kind = 'd' THEN current_balance - p_amount
                    ELSE current_balance
                END
        WHERE id = p_cliente_id
        RETURNING current_balance INTO v_current_balance;
    
    SELECT json_build_object(
        'current_balance', json_build_object(
            'total', v_current_balance,
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
    ) INTO v_balance;

    UPDATE members 
    SET balance = v_balance
        WHERE id = p_cliente_id;

    SELECT json_build_object(
        'current_balance', v_current_balance,
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
    row_count integer;
    v_current_balance numeric;
    v_limit numeric;
    v_balance TEXT;
BEGIN

    SELECT balance
        INTO v_balance
        FROM members
        WHERE id = p_cliente_id;

    result.body := v_balance;
    result.status_code := 200;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

INSERT INTO members(id) VALUES (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT);

SELECT proc_transacao(0,1,0,'d','init');
SELECT proc_transacao(0,2,0,'d','init');
SELECT proc_transacao(0,3,0,'d','init');
SELECT proc_transacao(0,4,0,'d','init');
SELECT proc_transacao(0,5,0,'d','init');