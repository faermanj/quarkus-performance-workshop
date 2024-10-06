
-- Create tables
CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INT NOT NULL,
    current_balance INT NOT NULL DEFAULT 0
);

CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(255) NOT NULL,
    submitted_at DATETIME NOT NULL DEFAULT now(),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- Insert initial data into clientes
INSERT INTO clientes (nome, limit) VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);


-- Procedure for transactions
CREATE PROCEDURE proc_transacao(IN p_cliente_id INT, IN p_amount INT, IN p_kind VARCHAR(1), IN p_description VARCHAR(255), OUT r_current_balance INT, OUT r_limit INT)
BEGIN
    DECLARE count INT;
    DECLARE diff INT;
    DECLARE n_current_balance INT;
    
    SELECT COUNT(*) into count 
        FROM clientes
        WHERE id = p_cliente_id;

    IF count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CLIENTE_NAO_ENCONTRADO';
        ROLLBACK;
    END IF;

    -- Determine transaction effect
    IF p_kind = 'd' THEN
        SET diff = p_amount * -1;
    ELSE
        SET diff = p_amount;
    END IF;

    -- Lock the clientes row
    SELECT current_balance, limit, r_current_balance + diff
        INTO r_current_balance, r_limit, n_current_balance
        FROM clientes 
        WHERE id = p_cliente_id 
        FOR UPDATE;

    -- Check if the new balance would exceed the limit
    IF (n_current_balance) < (-1 * r_limit) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'LIMITE_INDISPONIVEL';
        ROLLBACK;
    ELSE
        -- Update clientes current_balance
        UPDATE clientes SET current_balance = n_current_balance WHERE id = p_cliente_id;
        
        -- Insert into transactions
        INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at)
            VALUES (p_cliente_id, p_amount, p_kind, p_description, now(6));

        SELECT n_current_balance, r_limit AS resultado;
    END IF;
END;

CREATE PROCEDURE proc_balance(IN p_id INT)
BEGIN
    -- Check if the cliente exists
    IF NOT EXISTS (SELECT 1 FROM clientes WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CLIENTE_NAO_ENCONTRADO';
        ROLLBACK;
    END IF;

    -- Construct and return the entire JSON in a single query
    SELECT JSON_OBJECT(
        'current_balance', (
            SELECT JSON_OBJECT(
                'total', current_balance,
                'limit', limit
            )
            FROM clientes
            WHERE id = p_id
        ),
        'recent_transactions', (
            SELECT COALESCE(JSON_ARRAYAGG(
                JSON_OBJECT(
                    'amount', amount,
                    'kind', kind,
                    'description', description,
                    'submitted_at', DATE_FORMAT(submitted_at, '%Y-%m-%dT%H:%i:%sZ')
                )
            ), JSON_ARRAY()) 
            FROM transactions
            WHERE cliente_id = p_id
            ORDER BY submitted_at DESC
            LIMIT 10
        )
    ) AS balance;
END;
