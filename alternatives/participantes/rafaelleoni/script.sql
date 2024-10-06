CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    limit INT NOT NULL,
    current_balance INT NOT NULL DEFAULT 0
);


CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL CHECK (kind IN ('c', 'd')),
    description VARCHAR(10),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES members(id)
);


CREATE OR REPLACE FUNCTION atualizar_current_balance(id_cliente INTEGER, amount INTEGER, kind CHAR, description VARCHAR)
RETURNS TABLE (current_balance INTEGER, limit INTEGER) AS $$
DECLARE
    novo_current_balance INTEGER;
BEGIN
    -- Verifiar se cliente existe
    SELECT c.current_balance, c.limit INTO current_balance, limit FROM members c WHERE id = id_cliente;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'CLIENTE_NAO_ENCONTRADO';
    END IF;

    IF kind = 'c' THEN
        current_balance := current_balance + amount;
        
    ELSIF kind = 'd' THEN
        current_balance := current_balance - amount;

        -- Verificar se o current_balance após a transação de débito é menor que o limit
        IF current_balance < (-1 * limit) THEN
            RAISE EXCEPTION 'LIMITE_EXECEDIDO';
        END IF;
    END IF;

    novo_current_balance := current_balance;
    INSERT INTO transactions (id_cliente, amount, kind, description) VALUES (id_cliente, amount, kind, description);
    UPDATE members SET current_balance = novo_current_balance WHERE id = id_cliente;

    RETURN NEXT;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;


INSERT INTO 
    members (nome, limit)
VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);