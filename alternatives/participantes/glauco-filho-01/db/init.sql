-- Define o esquema de busca padrão para 'public'
SET search_path = public;

-- Define a codificação do cliente para UTF-8
SET client_encoding = 'UTF8';

-- Define as opções de XML para conteúdo
SET xmloption = content;

-- Define o nível mínimo de mensagens do cliente
SET client_min_messages = warning;

-- Desativa a segurança de linha
-- SET row_security = off;

-- Cria a tabela 'clientes' no esquema 'public'
CREATE TABLE public.clientes (
    id SERIAL PRIMARY KEY,  -- Coluna para o ID do cliente, usando SERIAL para autoincremento
    nome VARCHAR(22) UNIQUE,  -- Coluna para o nome do cliente, com restrição de unicidade
    limit INTEGER,  -- Coluna para o limit de crédito do cliente
    montante INTEGER  -- Coluna para o montante do cliente
);

-- Cria a tabela 'transactions' no esquema 'public'
CREATE TABLE public.transactions (
    id SERIAL PRIMARY KEY,  -- Coluna para o ID da transação, usando SERIAL para autoincremento
    cliente_id INTEGER REFERENCES public.clientes(id),  -- Coluna para o ID do cliente, com restrição de chave estrangeira referenciando 'clientes'
    amount INTEGER,  -- Coluna para o amount da transação
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Coluna para a data e hora da transação, usando a data e hora atual como padrão
    description VARCHAR(10),  -- Coluna para a descrição da transação
    kind CHAR(1)  -- Coluna para o kind de transação ('c' para crédito, 'd' para débito)
);

-- Cria a função 'inserir_credito' para inserir uma transação de crédito
CREATE OR REPLACE FUNCTION inserir_credito(cliente_id INT, amount INT, description VARCHAR)
RETURNS TABLE(novo_montante INT, cliente_limit INT) AS $$
DECLARE
    var_novo_montante INT;
    var_cliente_limit INT;
BEGIN
    -- Verifica se o cliente existe
    IF NOT EXISTS (SELECT 1 FROM public.clientes WHERE id = cliente_id) THEN
        RAISE EXCEPTION 'NOUSER';
    END IF;

    -- Obtém um bloqueio exclusivo para o cliente
    PERFORM pg_advisory_xact_lock(cliente_id);

    -- Insere a transação de crédito
    INSERT INTO public.transactions (cliente_id, amount, description, kind)
    VALUES (cliente_id, amount, description, 'c');

    -- Atualiza o current_balance do cliente e retorna montante e limit
    UPDATE public.clientes
    SET montante = montante + amount
    WHERE id = cliente_id
    RETURNING montante, limit INTO var_novo_montante, var_cliente_limit;

    -- Retorna os amountes
    RETURN QUERY SELECT var_novo_montante, var_cliente_limit;
END;
$$ LANGUAGE plpgsql;

-- Cria a função 'inserir_debito' para inserir uma transação de débito
CREATE OR REPLACE FUNCTION inserir_debito(cliente_id INT, amount INT, description VARCHAR)
RETURNS TABLE(novo_montante INT, cliente_limit INT) AS $$
DECLARE
    var_novo_montante INT;
    var_cliente_limit INT;
BEGIN
    -- Verifica se o cliente existe
    IF NOT EXISTS (SELECT 1 FROM public.clientes WHERE id = cliente_id) THEN
        RAISE EXCEPTION 'NOUSER';
    END IF;

    -- Obtém um bloqueio exclusivo para o cliente
    PERFORM pg_advisory_xact_lock(cliente_id);

    -- Verifica se o cliente tem current_balance suficiente
    IF NOT EXISTS (
        SELECT 1 FROM public.clientes
        WHERE id = cliente_id AND montante - amount >= -limit
    ) THEN
        RAISE EXCEPTION 'NOLIMIT';
    END IF;

    -- Insere a transação de débito
    INSERT INTO public.transactions (cliente_id, amount, description, kind)
    VALUES (cliente_id, amount, description, 'd'); -- Note o amount negativo

    -- Atualiza o current_balance do cliente e retorna montante e limit
    UPDATE public.clientes
    SET montante = montante - amount
    WHERE id = cliente_id
    RETURNING montante, limit INTO var_novo_montante, var_cliente_limit;

    -- Retorna os amountes
    RETURN QUERY SELECT var_novo_montante, var_cliente_limit;
END;
$$ LANGUAGE plpgsql;

-- Cria a função 'obter_recent_transactions' para obter as últimas transações de um cliente
CREATE OR REPLACE FUNCTION obter_recent_transactions(var_cliente_id INT)
RETURNS TABLE(amount INT, kind CHAR, description VARCHAR, submitted_at TIMESTAMP, montante INT, limit INT) AS $$
BEGIN
    -- Verifica se o cliente existe
    IF NOT EXISTS (SELECT 1 FROM public.clientes WHERE id = var_cliente_id) THEN
        RAISE EXCEPTION 'NOUSER';
    END IF;

    -- Obtém um bloqueio exclusivo para o cliente
    PERFORM pg_advisory_xact_lock(var_cliente_id);

    -- Retorna as últimas transações do cliente
    RETURN QUERY 
    SELECT t.amount, t.kind, t.description, t.submitted_at, c.montante, c.limit
    FROM public.transactions t
    JOIN public.clientes c ON t.cliente_id = c.id
    WHERE t.cliente_id = var_cliente_id
    ORDER BY t.id DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

-- Cria índices para otimizar consultas na tabela 'transactions'
CREATE INDEX idx_transactions_cliente_id ON public.transactions(cliente_id);
CREATE INDEX idx_transactions_submitted_at ON public.transactions(submitted_at);

-- Insere dados iniciais na tabela 'clientes'
DO $$
BEGIN
  INSERT INTO public.clientes (nome, limit, montante)
  VALUES
    ('o barato sai caro', 1000 * 100, 0),
    ('zan corp ltda', 800 * 100, 0),
    ('les cruders', 10000 * 100, 0),
    ('padaria joia de cocaia', 100000 * 100, 0),
    ('kid mais', 5000 * 100, 0);
END; $$
