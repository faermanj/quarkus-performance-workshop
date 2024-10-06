CREATE OR REPLACE FUNCTION proc_balance(p_id integer)
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