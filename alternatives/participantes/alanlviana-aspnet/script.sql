CREATE UNLOGGED TABLE clientes (
    codigo int PRIMARY KEY,
    limit DECIMAL(10) NOT NULL,
    current_balance DECIMAL(10) NOT NULL
);

CREATE UNLOGGED TABLE  transactions (
    codigo SERIAL PRIMARY KEY,
    description VARCHAR(50) NOT NULL,
    data_transacao TIMESTAMP NOT NULL,
    kind CHAR(1) CHECK (kind IN ('d', 'c')),
    amount DECIMAL(10) NOT NULL,
    codigo_cliente INTEGER REFERENCES clientes(codigo) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION realizar_transacao(
    p_codigo_cliente INTEGER,
    p_kind CHAR(1),
    p_description VARCHAR(50),
    p_amount DECIMAL(10)
) RETURNS TABLE (novo_current_balance DECIMAL(10), limit_cliente DECIMAL(10)) AS $$
DECLARE
    v_current_balance_cliente DECIMAL(10);
    v_limit_cliente DECIMAL(10);
BEGIN
    -- Obtém o current_balance e limit atuais do cliente
    SELECT current_balance, limit 
      INTO v_current_balance_cliente, v_limit_cliente 
      FROM clientes 
     WHERE codigo = p_codigo_cliente 
       FOR UPDATE ;

    -- Verifica se o cliente existe
    IF NOT FOUND THEN
        -- Cliente não encontrado, lança uma exceção
        RAISE EXCEPTION 'RN01:Cliente com código % não encontrado.', p_codigo_cliente;
    END IF;

   -- Valida se current_balance e limit permitem transacao
   if p_kind = 'd' then
   		if v_current_balance_cliente - p_amount < (v_limit_cliente * -1) then
   			raise exception 'RN02:Saldo e limit não permitem transacao.';
   		end if;
   end if;
   
   
    -- Verifica o kind de transação e realiza as operações necessárias
    IF p_kind = 'd' THEN
        -- Transação de débito
        UPDATE clientes SET current_balance = current_balance - p_amount WHERE codigo = p_codigo_cliente;
    ELSIF p_kind = 'c' THEN
        -- Transação de crédito
        UPDATE clientes SET current_balance = current_balance + p_amount WHERE codigo = p_codigo_cliente;
    ELSE
        -- Tipo de transação inválido
        RAISE EXCEPTION 'RN03:Tipo de transação inválido. Use "d" para débito ou "c" para crédito.';
    END IF;

    -- Insere a transação na tabela de transações
    INSERT INTO transactions (description, data_transacao, kind, amount, codigo_cliente)
         VALUES (p_description, CURRENT_TIMESTAMP, p_kind, p_amount, p_codigo_cliente);

    -- Retorna o novo current_balance e limit do cliente
    RETURN QUERY SELECT current_balance, limit FROM clientes WHERE codigo = p_codigo_cliente;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obter_current_balance_e_transactions(p_codigo_cliente INT)
RETURNS JSON
AS $$
DECLARE
    resultado JSON;
BEGIN
    -- Monta JSON com balance do cliente
    SELECT json_build_object(
        'current_balance', (SELECT * 
                    FROM json_build_object('total',c.current_balance, 'date_balance', current_timestamp, 'limit', c.limit)),
        'recent_transactions', (SELECT COALESCE(json_agg(ut.*), '[]'::json)
                                 FROM (
                                       SELECT t.description, t.kind, t.amount, t.data_transacao AS "submitted_at"
                                         FROM transactions t 
                                        WHERE t.codigo_cliente = c.codigo
                                        ORDER BY t.data_transacao DESC 
                                        LIMIT 10) as ut)
    )
    into resultado    
    FROM clientes c
    WHERE c.codigo = p_codigo_cliente;
   
    -- Verifica se o cliente existe
    IF NOT FOUND THEN
        -- Cliente não encontrado, lança uma exceção
        RAISE EXCEPTION 'RN01:Cliente com código % não encontrado.', p_codigo_cliente;
    END IF;
   

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

INSERT INTO clientes (codigo, limit, current_balance) VALUES 
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);
