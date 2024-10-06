CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    limit DECIMAL(10) NOT NULL,
    current_balance DECIMAL(10) NOT NULL
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES clientes(id) ON DELETE CASCADE,
    amount DECIMAL(10) NOT NULL,
    kind CHAR(1) CHECK (kind IN ('d', 'c')),
    description TEXT NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL
);




CREATE FUNCTION maker_transacao(input_cliente_id INT, input_kind VARCHAR, input_description VARCHAR, input_amount INT) 
RETURNS TABLE (current_balance INT, limit_cliente INT, falha BOOLEAN, mensagem VARCHAR(40)) AS $$
DECLARE
    falha_result BOOLEAN := false;
    mensagem_result VARCHAR(40) := '';
    limit_search INT;
    current_balance_search INT;
    amount_transacao_final INT;
BEGIN

        SELECT c.limit, c.current_balance 
            INTO limit_search, current_balance_search 
        FROM CLIENTES AS c 
            WHERE ID = input_cliente_id
        FOR UPDATE ;
        
      
        IF input_kind = 'c' THEN

            mensagem_result := 'Sucesso no credito';
            amount_transacao_final :=  current_balance_search + input_amount;
            UPDATE CLIENTES SET current_balance = amount_transacao_final WHERE id = input_cliente_id;

        ELSE
        
             
            IF ABS(current_balance_search) + input_amount > limit_search THEN

                mensagem_result := 'Cliente sem current_balance';
                falha_result := true;
                
            ELSE
            
                mensagem_result := 'Sucesso no debito';
                amount_transacao_final :=  current_balance_search - input_amount;
                UPDATE CLIENTES SET current_balance = amount_transacao_final  WHERE id = input_cliente_id;
            
            END IF;

        END IF;
       


    IF falha_result = false THEN
        INSERT INTO transactions (cliente_id,amount,kind,description,submitted_at) VALUES (input_cliente_id,input_amount,input_kind,input_description,NOW());
        RETURN QUERY SELECT amount_transacao_final, limit_search, falha_result, mensagem_result;
    ELSE
        RETURN QUERY SELECT 0, 0, falha_result, mensagem_result;

    END IF;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION proc_balance(p_id INT)
RETURNS JSON AS $$
DECLARE
    current_balance_info JSON;
BEGIN

    -- Construct and return the entire JSON in a single query
    SELECT JSON_BUILD_OBJECT(
        'current_balance', (
            SELECT JSON_BUILD_OBJECT(
                'total', current_balance,
                'limit', limit
            )
            FROM clientes
            WHERE id = p_id
        ),
        'recent_transactions', (
            SELECT COALESCE(
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'amount', amount,
                        'kind', kind,
                        'description', description,
                        'submitted_at', TO_CHAR(submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS"Z"')
                    ) ORDER BY submitted_at DESC
                ), 
                '[]'::JSON
            )
            FROM (
                SELECT amount, kind, description, submitted_at
                FROM transactions
                WHERE cliente_id = p_id
                ORDER BY submitted_at DESC
                LIMIT 10
            ) AS recent_transactions
        )
    ) INTO current_balance_info;

    RETURN current_balance_info;
END;
$$ LANGUAGE plpgsql;







INSERT INTO clientes (id, limit, current_balance) VALUES 
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);
