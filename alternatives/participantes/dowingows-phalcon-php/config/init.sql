CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    limit INT,
    current_balance INT
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    amount INT,
    kind CHAR(1),
    cliente_id INT,
    description VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cliente_e_suas_transactions ON transactions (cliente_id, submitted_at DESC);

INSERT INTO clientes (limit, current_balance) VALUES
(100000, 0),
(80000, 0),
(1000000, 0),
(10000000, 0),
(500000, 0);


CREATE OR REPLACE FUNCTION realizar_transacao(
    IN p_cliente_id INT,
    IN p_amount INT,
    IN p_description VARCHAR(10),
    IN p_kind CHAR(1)
)
RETURNS RECORD AS $$
DECLARE
    v_current_balance_atual INT;
    v_limit INT;
    ret RECORD;
BEGIN

    SELECT current_balance, limit INTO v_current_balance_atual, v_limit
    FROM clientes
    WHERE id = p_cliente_id
    FOR UPDATE; 

    IF p_kind = 'd' THEN
        IF (v_current_balance_atual - p_amount) < (-v_limit) THEN
            RAISE EXCEPTION 'Limite disponível atingido!';
        ELSE
            UPDATE clientes
            SET current_balance = current_balance - p_amount
            WHERE id = p_cliente_id 
            RETURNING current_balance, limit INTO ret;

            INSERT INTO transactions (amount, kind, cliente_id, description)
            VALUES (p_amount, 'd', p_cliente_id, p_description);
        END IF;
    ELSIF p_kind = 'c' THEN
        UPDATE clientes
        SET current_balance = current_balance + p_amount
        WHERE id = p_cliente_id
        RETURNING current_balance, limit INTO ret;

        INSERT INTO transactions (amount, kind, cliente_id, description)
        VALUES (p_amount, 'c', p_cliente_id, p_description);
    ELSE
        RAISE EXCEPTION 'Transação inválida!';
    END IF;

    RETURN ret;
END;
$$ LANGUAGE plpgsql;
