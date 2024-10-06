CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    current_balance INT NOT NULL DEFAULT 0
);

CREATE TABLE transactions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at DATETIME(6) NOT NULL,
    submitted_at_char VARCHAR(32) NOT NULL
);

CREATE INDEX idx_cliente_id ON transactions (cliente_id);

INSERT INTO clientes(id) VALUES (NULL), (NULL), (NULL), (NULL), (NULL);

DELIMITER $$

CREATE PROCEDURE proc_transacao(IN p_cliente_id INT, IN p_amount INT, IN p_kind CHAR(1), IN p_description VARCHAR(10))
BEGIN
    -- Example operation: Update current_balance based on kind
    IF p_kind = 'c' THEN
        UPDATE clientes SET current_balance = current_balance + p_amount WHERE id = p_cliente_id;
    ELSEIF p_kind = 'd' THEN
        UPDATE clientes SET current_balance = current_balance - p_amount WHERE id = p_cliente_id;
    END IF;

    -- Insert into transactions table
    INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at, submitted_at_char)
    VALUES (p_cliente_id, p_amount, p_kind, p_description, NOW(), DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s.%f'));
END$$

DELIMITER ;


DELIMITER $$

CREATE PROCEDURE proc_balance(IN p_cliente_id INT)
BEGIN
    DECLARE v_current_balance INT;
    DECLARE v_limit INT;
    DECLARE balance_json JSON;
    DECLARE transactions_json JSON;
    
    -- Determine v_limit based on cliente_id (similar logic to your CASE statement)
    SET v_limit = CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1
    END;

    -- Get current_balance for the cliente_id
    SELECT current_balance INTO v_current_balance FROM clientes WHERE id = p_cliente_id;

    -- Construct the JSON object for recent_transactions
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'amount', amount,
            'kind', kind,
            'description', description,
            'submitted_at_char', submitted_at_char
        )
    ) INTO transactions_json
    FROM (
        SELECT amount, kind, description, submitted_at_char
        FROM transactions
        WHERE cliente_id = p_cliente_id
        ORDER BY submitted_at DESC
        LIMIT 10
    ) AS subquery;

    -- Construct the final balance JSON object
    SET balance_json = JSON_OBJECT(
        'current_balance', JSON_OBJECT(
            'total', v_current_balance,
            'date_balance', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s.%f'),
            'limit', v_limit
        ),
        'recent_transactions', IFNULL(transactions_json, JSON_ARRAY())
    );
    
    -- Output the balance_json (in real-world usage, you might need to select or do something with this JSON)
    SELECT balance_json AS result;
END$$

DELIMITER ;
