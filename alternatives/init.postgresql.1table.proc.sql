-- Criando a tabela de transações com a coluna adicional current_balance
CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(255) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    current_balance INTEGER NOT NULL DEFAULT 0
);

-- Inserções iniciais
INSERT INTO transactions (cliente_id, amount, kind, description, current_balance)
VALUES 
    (1, 0, 'c', 'Deposito inicial', 0),
    (2, 0, 'c', 'Deposito inicial', 0),
    (3, 0, 'c', 'Deposito inicial', 0),
    (4, 0, 'c', 'Deposito inicial', 0),
    (5, 0, 'c', 'Deposito inicial', 0);

-- Preparando o ambiente
CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('transactions');

-- Definindo o kind para o resultado da transação
CREATE TYPE transacao_result AS (current_balance INT, limit INT);

-- Função para obter o limit do cliente
CREATE OR REPLACE FUNCTION limit_cliente(p_cliente_id INTEGER)
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

-- Procedure para realizar transações com lógica de limit
CREATE OR REPLACE PROCEDURE proc_transacao(p_cliente_id INT, p_amount INT, p_kind VARCHAR, p_description VARCHAR)
LANGUAGE plpgsql AS $$
DECLARE
    diff INT;
    v_current_balance_atual INT;
    v_novo_current_balance INT;
    v_limit INT;
BEGIN
    PERFORM pg_advisory_xact_lock(p_cliente_id);

    IF p_kind = 'd' THEN
        diff := -p_amount;
    ELSE
        diff := p_amount;
    END IF;

    -- Chamada para obter o limit do cliente
    v_limit := limit_cliente(p_cliente_id);

    SELECT current_balance 
        INTO v_current_balance_atual 
        FROM transactions 
        WHERE cliente_id = p_cliente_id 
        ORDER BY id 
        DESC LIMIT 1;

    IF NOT FOUND THEN
        v_current_balance_atual := 0;
    END IF;

    v_novo_current_balance := v_current_balance_atual + diff;

    IF p_kind = 'd' AND v_novo_current_balance < (-1 * v_limit) THEN
        RAISE EXCEPTION 'LIMITE_INDISPONIVEL';
    END IF;

    INSERT INTO transactions (cliente_id, amount, kind, description, current_balance)
    VALUES (p_cliente_id, amount, p_kind, p_description, v_novo_current_balance);

    
END;
$$;

-- Procedure para obter balance do cliente
CREATE OR REPLACE PROCEDURE proc_balance(p_cliente_id INTEGER)
LANGUAGE plpgsql AS $$
DECLARE
    v_current_balance INTEGER;
    v_limit INTEGER;
    transactions json;
BEGIN
    PERFORM pg_advisory_xact_lock(p_cliente_id);

    -- Chamada para obter o limit do cliente
    v_limit := limit_cliente(p_cliente_id);

    SELECT current_balance INTO v_current_balance FROM transactions WHERE cliente_id = p_cliente_id ORDER BY submitted_at DESC LIMIT 1;
    IF NOT FOUND THEN
        v_current_balance := 0;
    END IF;

    SELECT json_agg(row_to_json(t.*)) INTO transactions FROM (
        SELECT amount, kind, description, TO_CHAR(submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS submitted_at
        FROM transactions
        WHERE cliente_id = p_cliente_id
        ORDER BY id DESC
        LIMIT 10
    ) t;

    -- Nota: A exibição do resultado para o cliente deve ser feita por meio de uma aplicação ou consulta que chame esta procedure.
    -- Este script SQL não retorna diretamente o JSON, mas prepara os dados para serem consumidos.
END;
$$;
