
CREATE UNLOGGED TABLE transactions(
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    current_balance INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX transactions_idx ON transactions(cliente_id);
SET enable_seqscan=off;

CREATE TYPE json_result AS (
  body json,
  status_code INT
);

CREATE OR REPLACE FUNCTION calcular_current_balance(clientId INT, t_kind CHAR, t_amount DECIMAL, t_description CHAR(10) , t_limit INT)
    RETURNS json as $$
    DECLARE
        current_balance_atual INTEGER;
        limit_atual INTEGER;
        result json_result;
    BEGIN

        SELECT current_balance INTO current_balance_atual
        FROM transactions
        WHERE cliente_id = clientId
        ORDER BY submitted_at DESC, id DESC
        LIMIT 1;
        
        IF NOT FOUND THEN
            current_balance_atual := 0;
        END IF;

        limit_atual := t_limit;

        IF t_kind = 'd' THEN
            IF (current_balance_atual + (-1 * t_amount)) < (-1 * limit_atual) THEN
                result.body := '{"error": "Valor excede o limit de current_balance disponível"}';
                result.status_code := 422;
                RETURN json_build_object('error','amount excede o limit de current_balance disponível', 'code', 422);
            ELSE
                current_balance_atual := current_balance_atual + (-1 * t_amount);
            END IF;
        ELSIF t_kind = 'c' THEN
            -- Verificar se o novo current_balance ultrapassa o limit
            IF (current_balance_atual + t_amount) > limit_atual THEN
                result.body :=  '{"error": "Valor excede o limit de crédito disponível"}';
                result.status_code := 422;
                RETURN json_build_object('error', 'Valor excede o limit de crédito disponível', 'code',422);
            ELSE
                current_balance_atual := current_balance_atual + t_amount;
            END IF;
        ELSE
            result.body := '{"error": "Tipo de transação inválido"}';
            result.status_code := 400;
            RETURN json_build_object('error','Tipo de transação inválido', 'code', 400);
        END IF;

        INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at, current_balance)
        VALUES (clientId, t_amount, t_kind, t_description, now(), current_balance_atual);

    RETURN json_build_object('current_balance', current_balance_atual,'limit', t_limit, 'code', 200);

EXCEPTION
    WHEN OTHERS THEN
        RAISE 'Error processing transaction: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;