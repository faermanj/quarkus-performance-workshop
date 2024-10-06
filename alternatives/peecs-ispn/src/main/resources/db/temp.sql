
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE proc_transacao(
    IN p_cliente_id INT, 
    IN p_amount INT, 
    IN p_kind CHAR(1), 
    IN p_description VARCHAR(10),
    OUT result_body TEXT, 
    OUT result_status_code INT
)
BEGIN
    DECLARE v_current_balance INT;
    DECLARE v_limit INT;
    
    -- Determine the limit based on cliente_id
    SET v_limit = CASE p_cliente_id
        WHEN 1 THEN 100000
        WHEN 2 THEN 80000
        WHEN 3 THEN 1000000
        WHEN 4 THEN 10000000
        WHEN 5 THEN 500000
        ELSE -1 -- Default case if cliente_id is not between 1 and 5
    END;
    
    -- Fetch current balance and lock the row
    SELECT current_balance INTO v_current_balance FROM clientes WHERE id = p_cliente_id FOR UPDATE;
    
    -- Check if the transaction exceeds the limit for debits
    IF p_kind = 'd' AND (v_current_balance - p_amount) < (-1 * v_limit) THEN
        SET result_body = JSON_OBJECT('error', 'LIMITE_INDISPONIVEL');
        SET result_status_code = 422; -- Unprocessable Entity
    ELSE
        -- Proceed with inserting the transaction
        INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at, submitted_at_char)
        VALUES (p_cliente_id, p_amount, p_kind, p_description, NOW(), DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s.%f'));
        
        -- Update the balance
        UPDATE clientes 
        SET current_balance = CASE WHEN p_kind = 'c' THEN current_balance + p_amount
                         WHEN p_kind = 'd' THEN current_balance - p_amount
                    END 
        WHERE id = p_cliente_id;
        
        -- Fetch the updated balance
        SELECT current_balance INTO v_current_balance FROM clientes WHERE id = p_cliente_id;
        
        -- Prepare the success response
        SET result_body = JSON_OBJECT('current_balance', v_current_balance, 'limit', v_limit);
        SET result_status_code = 200; -- OK
    END IF;
END$$

DELIMITER ;
