CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	limite INTEGER NOT NULL,
	saldo INTEGER NOT NULL DEFAULT 0
);

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

    
CREATE UNLOGGED TABLE transacoes (
	id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP(6) NOT NULL
);

CREATE INDEX idx_realizada_em ON transacoes (realizada_em);


INSERT INTO clientes (nome, limite) VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);

INSERT INTO transacoes (cliente_id, valor, tipo, descricao, realizada_em)
    SELECT id, 0, 'c', 'init', now()
    FROM clientes;


CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('clientes');
SELECT pg_prewarm('transacoes');


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

CREATE TYPE json_result AS (
  status_code INT,
  body json
);

CREATE OR REPLACE FUNCTION proc_transacao(p_cliente_id INT, p_valor INT, p_tipo CHAR, p_descricao CHAR(10))
RETURNS json_result as $$
DECLARE
    diff INT;
    v_saldo INT;
    v_limite INT;
    result json_result;
BEGIN
    SELECT limite_cliente(p_cliente_id) INTO v_limite;
    
    SELECT saldo 
        INTO v_saldo
        FROM clientes
        WHERE id = p_cliente_id
        FOR UPDATE;

    IF p_tipo = 'd' THEN
        diff := p_valor * -1;            
        IF (v_saldo + diff) < (-1 * v_limite) THEN
            result.body := 'LIMITE_INDISPONIVEL';
            result.status_code := 422;
            RETURN result;
        END IF;
    ELSE
        diff := p_valor;
    END IF;

    
    INSERT INTO transacoes 
                     (cliente_id,   valor,   tipo,   descricao,      realizada_em)
            VALUES (p_cliente_id, p_valor, p_tipo, p_descricao, now());

    UPDATE clientes 
        SET saldo = saldo + diff 
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


CREATE OR REPLACE FUNCTION proc_extrato(p_cliente_id int)
RETURNS json_result AS $$
DECLARE
    result json_result;
    row_count integer;
    v_saldo numeric;
    v_limite numeric;
BEGIN

    SELECT saldo
        INTO v_saldo
        FROM clientes
        WHERE id = p_cliente_id;

    IF NOT FOUND THEN
            result.body := 'CLIENTE_NAO_ENCONTRADO';
            result.status_code := 404;
            RETURN result;
    END IF;

    SELECT limite_cliente(p_cliente_id) INTO v_limite;
    SELECT json_build_object(
        'saldo', json_build_object(
            'total', v_saldo,
            'data_extrato', TO_CHAR(now(), 'YYYY-MM-DD HH:MI:SS.US'),
            'limite', v_limite
        ),
        'ultimas_transacoes', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT valor, tipo, descricao, TO_CHAR(realizada_em, 'YYYY-MM-DD HH:MI:SS.US') as realizada_em
                FROM transacoes
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
