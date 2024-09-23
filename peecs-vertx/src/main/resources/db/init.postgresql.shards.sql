CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	saldo INTEGER NOT NULL DEFAULT 0
);
    
CREATE UNLOGGED TABLE transactions (
	id INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL);

CREATE INDEX idx_cliente_id ON transactions (cliente_id);

INSERT INTO members(id) VALUES (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT), (DEFAULT);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
SELECT pg_prewarm('transactions');

CREATE TYPE json_result AS (
  status_code INT,
  body json
);

CREATE OR REPLACE FUNCTION proc_transacao(p_shard INT, p_cliente_id INT, p_valor INT, p_tipo CHAR, p_descricao CHAR(10))
RETURNS json_result as $$
DECLARE
    diff INT;
    v_saldo INT;
    v_limite INT;
    result json_result;
BEGIN
    -- SELECT limite_cliente(p_cliente_id) INTO v_limite;
    v_limite := CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1 -- Valor padrão caso o id do cliente não esteja entre 1 e 5
    END;

    SELECT saldo 
        INTO v_saldo
        FROM members
        WHERE id = p_cliente_id
        FOR UPDATE;

    IF p_tipo = 'd' AND ((v_saldo - p_valor) < (-1 * v_limite)) THEN
            result.body := 'LIMITE_INDISPONIVEL';
            result.status_code := 422;
            RETURN result;
    END IF;
    
    INSERT INTO transactions 
                     (cliente_id,   valor,   tipo,   descricao,      realizada_em)
            VALUES (p_cliente_id, p_valor, p_tipo, p_descricao, now());

    UPDATE members 
    SET saldo = CASE 
                    WHEN p_tipo = 'c' THEN saldo + p_valor
                    WHEN p_tipo = 'd' THEN saldo - p_valor
                    ELSE saldo
                END
        WHERE id = p_cliente_id
        RETURNING saldo INTO v_saldo;


    SELECT json_build_object(
        'saldo', v_saldo,
        'limite', v_limite
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
    v_saldo numeric;
    v_limite numeric;
BEGIN

    SELECT saldo
        INTO v_saldo
        FROM members
        WHERE id = p_cliente_id;

    v_limite := CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1 -- Valor padrão caso o id do cliente não esteja entre 1 e 5
    END;

    SELECT json_build_object(
        'saldo', json_build_object(
            'total', v_saldo,
            'date_balance', TO_CHAR(now(), 'YYYY-MM-DD HH:MI:SS.US'),
            'limite', v_limite
        ),
        'ultimas_transactions', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT valor, tipo, descricao
                FROM transactions
                WHERE cliente_id = p_cliente_id
                ORDER BY realizada_em DESC
                LIMIT 10
            ) t
        ), '[]')
    ) INTO result.body;
    result.status_code := 200;
    RETURN result;
END;
$$ LANGUAGE plpgsql;
