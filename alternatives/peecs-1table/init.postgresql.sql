CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(255) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO clientes (nome, limit) VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);
CREATE TYPE transacao_result AS (current_balance INT, limit INT);

CREATE OR REPLACE FUNCTION proc_transacao(p_cliente_id INT, p_amount INT, p_kind VARCHAR, p_description VARCHAR)
RETURNS transacao_result as $$
DECLARE
    diff INT;
    v_current_balance INT;
    v_limit INT;
    result transacao_result;
BEGIN
    IF p_kind = 'd' THEN
        diff := p_amount * -1;
    ELSE
        diff := p_amount;
    END IF;

    PERFORM * FROM clientes WHERE id = p_cliente_id FOR UPDATE;


    UPDATE clientes 
        SET current_balance = current_balance + diff 
        WHERE id = p_cliente_id
        RETURNING current_balance, limit INTO v_current_balance, v_limit;

    IF (v_current_balance + diff) < (-1 * v_limit) THEN
        RAISE 'LIMITE_INDISPONIVEL [%, %, %]', v_current_balance, diff, v_limit;
    ELSE
        result := (v_current_balance, v_limit)::transacao_result;
        INSERT INTO transactions (cliente_id, amount, kind, description)
            VALUES (p_cliente_id, p_amount, p_kind, p_description);
        RETURN result;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE 'Error processing transaction: %', SQLERRM;
        ROLLBACK;
END;
$$ LANGUAGE plpgsql;CREATE OR REPLACE FUNCTION proc_balance(p_id integer)
RETURNS json AS $$
DECLARE
    result json;
    row_count integer;
    v_current_balance numeric;
    v_limit numeric;
BEGIN
    SELECT current_balance, limit
    INTO v_current_balance, v_limit
    FROM clientes
    WHERE id = p_id;

    GET DIAGNOSTICS row_count = ROW_COUNT;

    IF row_count = 0 THEN
        RAISE EXCEPTION 'CLIENTE_NAO_ENCONTRADO %', p_id;
    END IF;

    SELECT json_build_object(
        'current_balance', json_build_object(
            'total', v_current_balance,
            'date_balance', TO_CHAR(NOW(), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
            'limit', v_limit
        ),
        'recent_transactions', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') as submitted_at
                FROM transactions
                WHERE cliente_id = p_id
                ORDER BY submitted_at DESC
                LIMIT 10
            ) t
        ), '[]')
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql;
-- SQL init done
