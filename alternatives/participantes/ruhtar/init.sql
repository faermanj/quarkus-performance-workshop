CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    limit INTEGER NOT NULL
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_members_transactions_id
        FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE current_balances (
   id SERIAL PRIMARY KEY,
   cliente_id INTEGER NOT NULL,
   amount INTEGER NOT NULL,
   CONSTRAINT fk_members_current_balances_id
       FOREIGN KEY (cliente_id) REFERENCES members(id)
);


CREATE INDEX idx_members_id ON members (id);
CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);
CREATE INDEX idx_current_balances_cliente_id ON current_balances (cliente_id);

BEGIN TRANSACTION;

INSERT INTO members (nome, limit)
VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);

INSERT INTO current_balances (cliente_id, amount)
SELECT id, 0 FROM members;

CREATE OR REPLACE FUNCTION atualizar_current_balance_transacao(
    cliente_id_param INTEGER,
    amount_transacao_param INTEGER,
    kind_transacao_param CHAR(1),
    description_transacao_param VARCHAR(10) 
) RETURNS TABLE(success BOOLEAN, new_current_balance INTEGER) AS
$$
DECLARE
    limit_cliente INTEGER;
    current_balance_amount INTEGER;
    novo_current_balance INTEGER;
    description VARCHAR(10);
BEGIN
    -- Obter o limit do cliente
    SELECT limit INTO limit_cliente FROM members WHERE id = cliente_id_param; -- FOR UPDATE --POSSO ALTERAR ISSO PQ ELE NÃO PRECISA CONSULTAR ISSO
    
    -- Obter o current_balance atual do cliente
    SELECT amount INTO current_balance_amount FROM current_balances WHERE cliente_id = cliente_id_param FOR UPDATE; -- FOR UPDATE
    
    -- Calcular o novo current_balance com base no kind de transação
    IF kind_transacao_param = 'c' THEN
        novo_current_balance := current_balance_amount + amount_transacao_param;
    ELSE
        novo_current_balance := current_balance_amount - amount_transacao_param;
    END IF;
    
    -- Verificar se o novo current_balance ultrapassa o limit
    IF (limit_cliente + novo_current_balance) < 0 THEN
        -- Se sim, fazer rollback e retornar false
        RETURN QUERY SELECT false, null::INTEGER;
    ELSE
        -- Se não, atualizar o current_balance do cliente e inserir a transação
        UPDATE current_balances SET amount = novo_current_balance WHERE cliente_id = cliente_id_param;
        
        INSERT INTO transactions (cliente_id, amount, kind, description) 
        VALUES (cliente_id_param, amount_transacao_param, kind_transacao_param, description_transacao_param);

        -- Se bem-sucedido, retornar true e o novo current_balance
        RETURN QUERY SELECT true, novo_current_balance;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, fazer rollback e retornar false
        RETURN QUERY SELECT false, null::INTEGER;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ObterSaldoEtransactions(clienteId integer)
RETURNS TABLE (current_balance integer, recent_transactions jsonb)
AS $$
DECLARE
    current_balance_result integer;
    transactions_result jsonb;
BEGIN
    -- Consulta de Saldo
    SELECT amount INTO current_balance_result FROM current_balances WHERE cliente_id = clienteId; -- FOR UPDATE

    SELECT jsonb_agg(jsonb_build_object('amount', t.amount, 'kind', t.kind, 'description', t.description, 'submitted_at', t.submitted_at))
INTO transactions_result
FROM (
    SELECT amount, kind, description, submitted_at
    FROM transactions
    WHERE cliente_id = clienteId
    ORDER BY submitted_at DESC
    LIMIT 10
) t;

    -- Retornar os resultados
    RETURN QUERY SELECT current_balance_result, transactions_result;
END;
$$
LANGUAGE plpgsql;

COMMIT;
