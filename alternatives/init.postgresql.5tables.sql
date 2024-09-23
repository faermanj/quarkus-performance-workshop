-- Criando as tabelas de transações para cada cliente
CREATE UNLOGGED TABLE transactions_1 (
	id SERIAL PRIMARY KEY,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL,
    saldo INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_2 (
	id SERIAL PRIMARY KEY,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL,
    saldo INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_3 (
	id SERIAL PRIMARY KEY,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL,
    saldo INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_4 (
	id SERIAL PRIMARY KEY,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL,
    saldo INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions_5 (
	id SERIAL PRIMARY KEY,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL,
    saldo INTEGER NOT NULL
);


-- A extensão e a função limite_cliente permanecem inalteradas

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('transactions_1'), pg_prewarm('transactions_2'), pg_prewarm('transactions_3'), pg_prewarm('transactions_4'), pg_prewarm('transactions_5');

CREATE OR REPLACE FUNCTION limite_cliente(p_cliente_id INTEGER)
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

CREATE TYPE transacao_result AS (saldo INT, limite INT);

-- Função limite_cliente permanece igual
CREATE OR REPLACE FUNCTION proc_transacao(p_cliente_id INT, p_valor INT, p_tipo CHAR, p_descricao VARCHAR(10))
RETURNS transacao_result AS $$
DECLARE
    diff INT;
    v_saldo INT;
    v_limite INT;
    result transacao_result;
BEGIN
    SELECT limite_cliente(p_cliente_id) INTO v_limite;

    IF p_cliente_id = 1 THEN
        LOCK TABLE transactions_1 IN ACCESS EXCLUSIVE MODE;
        SELECT saldo INTO v_saldo FROM transactions_1 ORDER BY id DESC LIMIT 1;

        IF p_tipo = 'd' THEN
            diff := p_valor * -1;
        ELSE
            diff := p_valor;
        END IF;

        IF (v_saldo + diff) < (-1 * v_limite) THEN
            RAISE EXCEPTION 'LIMITE_INDISPONIVEL [%]', p_cliente_id;
        END IF;

        INSERT INTO transactions_1(valor, tipo, descricao, realizada_em, saldo)
        VALUES (p_valor, p_tipo, p_descricao, clock_timestamp(), v_saldo + diff);

    ELSIF p_cliente_id = 2 THEN
        LOCK TABLE transactions_2 IN ACCESS EXCLUSIVE MODE;
        SELECT saldo INTO v_saldo FROM transactions_2 ORDER BY id DESC LIMIT 1;

        IF p_tipo = 'd' THEN
            diff := p_valor * -1;
        ELSE
            diff := p_valor;
        END IF;

        IF (v_saldo + diff) < (-1 * v_limite) THEN
            RAISE EXCEPTION 'LIMITE_INDISPONIVEL [%]', p_cliente_id;
        END IF;

        INSERT INTO transactions_2(valor, tipo, descricao, realizada_em, saldo)
        VALUES (p_valor, p_tipo, p_descricao, clock_timestamp(), v_saldo + diff);

    -- Repita esta lógica para transactions_3, transactions_4, e transactions_5
    -- Exemplo para transactions_3:
    ELSIF p_cliente_id = 3 THEN
        LOCK TABLE transactions_3 IN ACCESS EXCLUSIVE MODE;
        SELECT saldo INTO v_saldo FROM transactions_3 ORDER BY id DESC LIMIT 1;

        IF p_tipo = 'd' THEN
            diff := p_valor * -1;
        ELSE
            diff := p_valor;
        END IF;

        IF (v_saldo + diff) < (-1 * v_limite) THEN
            RAISE EXCEPTION 'LIMITE_INDISPONIVEL [%]', p_cliente_id;
        END IF;

        INSERT INTO transactions_3(valor, tipo, descricao, realizada_em, saldo)
        VALUES (p_valor, p_tipo, p_descricao, clock_timestamp(), v_saldo + diff);

    -- Adicione condicionais semelhantes para p_cliente_id = 4 e p_cliente_id = 5, ajustando para transactions_4 e transactions_5 respectivamente.
    
    ELSE
        RAISE EXCEPTION 'CLIENTE_NAO_ENCONTRADO [%]', p_cliente_id;
    END IF;

    result := ROW(v_saldo + diff, v_limite)::transacao_result;
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
    v_saldo INT;
    v_limite INT;
BEGIN
    SELECT limite_cliente(p_cliente_id) INTO v_limite;

    IF p_cliente_id = 1 THEN
        LOCK TABLE transactions_1 IN ACCESS SHARE MODE;
        SELECT saldo INTO v_saldo FROM transactions_1 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'saldo', json_build_object(
                'total', v_saldo,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limite', v_limite
            ),
            'ultimas_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT valor, tipo, descricao, TO_CHAR(realizada_em, 'YYYY-MM-DD HH24:MI:SS.US') AS realizada_em
                    FROM transactions_1
                    ORDER BY realizada_em DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 2 THEN
        LOCK TABLE transactions_2 IN ACCESS SHARE MODE;
        SELECT saldo INTO v_saldo FROM transactions_2 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'saldo', json_build_object(
                'total', v_saldo,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limite', v_limite
            ),
            'ultimas_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT valor, tipo, descricao, TO_CHAR(realizada_em, 'YYYY-MM-DD HH24:MI:SS.US') AS realizada_em
                    FROM transactions_2
                    ORDER BY realizada_em DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 3 THEN
        LOCK TABLE transactions_3 IN ACCESS SHARE MODE;
        SELECT saldo INTO v_saldo FROM transactions_3 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'saldo', json_build_object(
                'total', v_saldo,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limite', v_limite
            ),
            'ultimas_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT valor, tipo, descricao, TO_CHAR(realizada_em, 'YYYY-MM-DD HH24:MI:SS.US') AS realizada_em
                    FROM transactions_3
                    ORDER BY realizada_em DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 4 THEN
        LOCK TABLE transactions_4 IN ACCESS SHARE MODE;
        SELECT saldo INTO v_saldo FROM transactions_4 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'saldo', json_build_object(
                'total', v_saldo,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limite', v_limite
            ),
            'ultimas_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT valor, tipo, descricao, TO_CHAR(realizada_em, 'YYYY-MM-DD HH24:MI:SS.US') AS realizada_em
                    FROM transactions_4
                    ORDER BY realizada_em DESC, id DESC
                    LIMIT 10
                ) t
            ), '[]')
        ) INTO result;

    ELSIF p_cliente_id = 5 THEN
        LOCK TABLE transactions_5 IN ACCESS SHARE MODE;
        SELECT saldo INTO v_saldo FROM transactions_5 ORDER BY id DESC LIMIT 1;

        SELECT json_build_object(
            'saldo', json_build_object(
                'total', v_saldo,
                'date_balance', TO_CHAR(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.US'),
                'limite', v_limite
            ),
            'ultimas_transactions', COALESCE((
                SELECT json_agg(row_to_json(t))
                FROM (
                    SELECT valor, tipo, descricao, TO_CHAR(realizada_em, 'YYYY-MM-DD HH24:MI:SS.US') AS realizada_em
                    FROM transactions_5
                    ORDER BY realizada_em DESC, id DESC
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
