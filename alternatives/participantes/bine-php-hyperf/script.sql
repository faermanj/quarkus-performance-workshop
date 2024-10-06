USE rinha;

CREATE TABLE IF NOT EXISTS clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    limit INT NOT NULL,
    current_balance INT DEFAULT 0 NOT NULL,
    CHECK (current_balance >= -limit)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

CREATE INDEX idx_cliente_id ON transactions(cliente_id);

DELIMITER //
CREATE TRIGGER create_transaction_trigger
BEFORE INSERT
ON transactions FOR EACH ROW
BEGIN
    DECLARE v_limit INT;
    DECLARE v_current_balance INT;

    IF NEW.amount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Transaction amount cannot be negative!';
    END IF;

    SELECT limit, current_balance INTO v_limit, v_current_balance FROM clientes WHERE id = NEW.cliente_id;

    IF NEW.kind = 'c' THEN
        UPDATE clientes SET current_balance = current_balance + NEW.amount WHERE id = NEW.cliente_id;
    ELSEIF NEW.kind = 'd' THEN
        IF (v_current_balance + v_limit - NEW.amount) < 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Debit exceeds customer limit and balance!';
        ELSE
            UPDATE clientes SET current_balance = current_balance - NEW.amount WHERE id = NEW.cliente_id;
        END IF;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid transaction!';
    END IF;
END;
//
DELIMITER ;

INSERT INTO clientes (nome, limit)
VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
