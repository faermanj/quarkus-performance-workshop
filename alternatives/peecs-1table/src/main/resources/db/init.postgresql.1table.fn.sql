CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL,
    current_balance INTEGER NOT NULL
);

INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at, current_balance) VALUES
    (1 , 0, 'c', 'init', clock_timestamp(), 0),
    (2 , 0, 'c', 'init', clock_timestamp(), 0),
    (3 , 0, 'c', 'init', clock_timestamp(), 0),
    (4 , 0, 'c', 'init', clock_timestamp(), 0),
    (5 , 0, 'c', 'init', clock_timestamp(), 0);


CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('transactions');


CREATE OR REPLACE FUNCTION limit_cliente(p_cliente_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1 -- Valor padrão caso o id do cliente não esteja entre 1 e 5
    END;
END;
$$ LANGUAGE plpgsql;

CREATE TYPE transacao_result AS (current_balance INT, limit INT);

CREATE OR REPLACE FUNCTION proc_transacao(p_cliente_id INT, p_amount INT, p_kind CHAR, p_description CHAR(10))
RETURNS transacao_result as $$
DECLARE
    diff INT;
    v_current_balance INT;
    v_limit INT;
    result transacao_result;
BEGIN
    -- PERFORM pg_try_advisory_xact_lock(42);
    PERFORM pg_advisory_lock(p_cliente_id);
    -- PERFORM pg_try_advisory_xact_lock(p_cliente_id);
    -- PERFORM pg_advisory_xact_lock(p_cliente_id);
    -- lock table clientes in ACCESS EXCLUSIVE mode;
    -- lock table transactions in ACCESS EXCLUSIVE mode;

    -- invoke limit_cliente into v_limit
    SELECT limit_cliente(p_cliente_id) INTO v_limit;
    
    SELECT current_balance 
        FROM transactions
        WHERE id = p_cliente_id
        ORDER BY submitted_at DESC
        LIMIT 1
        INTO v_current_balance;

    IF p_kind = 'd' THEN
        diff := p_amount * -1;            
        IF (v_current_balance + diff) < (-1 * v_limit) THEN
            RAISE 'LIMITE_INDISPONIVEL [%, %, %]', v_current_balance, diff, v_limit;
        END IF;
    ELSE
        diff := p_amount;
    END IF;

    
    INSERT INTO transactions 
                     (cliente_id,   amount,   kind,   description,      submitted_at, current_balance)
            VALUES (p_cliente_id, p_amount, p_kind, p_description, clock_timestamp(), v_current_balance + diff);

    result := (v_current_balance, v_limit)::transacao_result;
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RAISE 'Error processing transaction: %', SQLERRM;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION proc_balance(p_cliente_id int)
RETURNS json AS $$
DECLARE
    result json;
    row_count integer;
    v_current_balance numeric;
    v_limit numeric;
BEGIN
    -- PERFORM pg_try_advisory_xact_lock(42);
    PERFORM pg_try_advisory_xact_lock(p_cliente_id);
    -- PERFORM pg_try_advisory_lock(p_cliente_id);
    -- PERFORM pg_advisory_xact_lock(p_cliente_id);
    -- lock table clientes in ACCESS EXCLUSIVE mode;
    -- lock table transactions in ACCESS EXCLUSIVE mode;

    SELECT current_balance 
        INTO v_current_balance
        FROM transactions
        WHERE id = p_cliente_id
        ORDER BY submitted_at DESC
        LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'CLIENTE_NAO_ENCONTRADO %', p_cliente_id;
    END IF;

    SELECT limit_cliente(p_cliente_id) INTO v_limit;
    SELECT json_build_object(
        'current_balance', json_build_object(
            'total', v_current_balance,
            'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH:MI:SS.US'),
            'limit', v_limit
        ),
        'recent_transactions', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD HH:MI:SS.US') as submitted_at
                FROM transactions
                WHERE cliente_id = p_cliente_id
                ORDER BY submitted_at DESC
                -- ORDER BY id DESC
                LIMIT 10
            ) t
        ), '[]')
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql;
-- SQL init done