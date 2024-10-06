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

    -- Is this necessary?
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
$$ LANGUAGE plpgsql;