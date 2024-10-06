-- Criando as tabelas de transações para cada cliente
CREATE UNLOGGED TABLE transactions_1 (
	id SERIAL PRIMARY KEY,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_2 (
	id SERIAL PRIMARY KEY,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_3 (
	id SERIAL PRIMARY KEY,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_4 (
	id SERIAL PRIMARY KEY,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_5 (
	id SERIAL PRIMARY KEY,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP(6) NOT NULL,
    current_balance INTEGER NOT NULL
);


-- A extensão e a função limit_cliente permanecem inalteradas

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('transactions_1'), pg_prewarm('transactions_2'), pg_prewarm('transactions_3'), pg_prewarm('transactions_4'), pg_prewarm('transactions_5');

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

-- Função limit_cliente permanece igual
CREATE OR REPLACE FUNCTION proc_transacao(p_cliente_id INT, p_amount INT, p_kind CHAR, p_description VARCHAR(10))
RETURNS transacao_result AS $$
DECLARE
    diff INT;
    v_current_balance INT;
    v_limit INT;
    result transacao_result;
BEGIN
    SELECT limit_cliente(p_cliente_id) INTO v_limit;

    IF p_cliente_id = 1 THEN
        LOCK TABLE transactions_1 IN ACCESS EXCLUSIVE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_1 ORDER BY id DESC LIMIT 1;

        IF p_kind = 'd' THEN
            diff := p_amount * -1;
        ELSE
            diff := p_amount;
        END IF;

        IF (v_current_balance + diff) < (-1 * v_limit) THEN
            RAISE EXCEPTION 'LIMITE_INDISPONIVEL [%]', p_cliente_id;
        END IF;

        INSERT INTO transactions_1(amount, kind, description, submitted_at, current_balance)
        VALUES (p_amount, p_kind, p_description, clock_timestamp(), v_current_balance + diff);

    ELSIF p_cliente_id = 2 THEN
        LOCK TABLE transactions_2 IN ACCESS EXCLUSIVE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_2 ORDER BY id DESC LIMIT 1;

        IF p_kind = 'd' THEN
            diff := p_amount * -1;
        ELSE
            diff := p_amount;
        END IF;

        IF (v_current_balance + diff) < (-1 * v_limit) THEN
            RAISE EXCEPTION 'LIMITE_INDISPONIVEL [%]', p_cliente_id;
        END IF;

        INSERT INTO transactions_2(amount, kind, description, submitted_at, current_balance)
        VALUES (p_amount, p_kind, p_description, clock_timestamp(), v_current_balance + diff);

    -- Repita esta lógica para transactions_3, transactions_4, e transactions_5
    -- Exemplo para transactions_3:
    ELSIF p_cliente_id = 3 THEN
        LOCK TABLE transactions_3 IN ACCESS EXCLUSIVE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_3 ORDER BY id DESC LIMIT 1;

        IF p_kind = 'd' THEN
            diff := p_amount * -1;
        ELSE
            diff := p_amount;
        END IF;

        IF (v_current_balance + diff) < (-1 * v_limit) THEN
            RAISE EXCEPTION 'LIMITE_INDISPONIVEL [%]', p_cliente_id;
        END IF;

        INSERT INTO transactions_3(amount, kind, description, submitted_at, current_balance)
        VALUES (p_amount, p_kind, p_description, clock_timestamp(), v_current_balance + diff);

    -- Adicione condicionais semelhantes para p_cliente_id = 4 e p_cliente_id = 5, ajustando para transactions_4 e transactions_5 respectivamente.
    
    ELSE
        RAISE EXCEPTION 'CLIENTE_NAO_ENCONTRADO [%]', p_cliente_id;
    END IF;

    result := ROW(v_current_balance + diff, v_limit)::transacao_result;
    RETURN result;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao processar transação: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION proc_balance(p_cliente_id INT)
RETURNS json AS $$
DECLARE
    result json;
    v_current_balance INT;
    v_limit INT;
BEGIN
    SELECT limit_cliente(p_cliente_id) INTO v_limit;

    IF p_cliente_id = 1 THEN
        LOCK TABLE transactions_1 IN ACCESS SHARE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_1 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'current_balance', json_build_object(
                'total', v_current_balance,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limit', v_limit
            ),
            'recent_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD HH24:MI:SS.US') AS submitted_at
                    FROM transactions_1
                    ORDER BY submitted_at DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 2 THEN
        LOCK TABLE transactions_2 IN ACCESS SHARE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_2 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'current_balance', json_build_object(
                'total', v_current_balance,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limit', v_limit
            ),
            'recent_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD HH24:MI:SS.US') AS submitted_at
                    FROM transactions_2
                    ORDER BY submitted_at DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 3 THEN
        LOCK TABLE transactions_3 IN ACCESS SHARE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_3 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'current_balance', json_build_object(
                'total', v_current_balance,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limit', v_limit
            ),
            'recent_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD HH24:MI:SS.US') AS submitted_at
                    FROM transactions_3
                    ORDER BY submitted_at DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 4 THEN
        LOCK TABLE transactions_4 IN ACCESS SHARE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_4 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'current_balance', json_build_object(
                'total', v_current_balance,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limit', v_limit
            ),
            'recent_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD HH24:MI:SS.US') AS submitted_at
                    FROM transactions_4
                    ORDER BY submitted_at DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 5 THEN
        LOCK TABLE transactions_5 IN ACCESS SHARE MODE;
        SELECT current_balance INTO v_current_balance FROM transactions_5 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'current_balance', json_build_object(
                'total', v_current_balance,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limit', v_limit
            ),
            'recent_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD HH24:MI:SS.US') AS submitted_at
                    FROM transactions_5
                    ORDER BY submitted_at DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSE
        RAISE EXCEPTION 'CLIENTE_NAO_ENCONTRADO %', p_cliente_id;
    END IF;

    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao processar balance: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
