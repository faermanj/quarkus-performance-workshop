DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clients;

CREATE UNLOGGED TABLE clients (
    id SERIAL PRIMARY KEY,
    limit INT NOT NULL,
    current_balance BIGINT DEFAULT 0
);
/* client searching index */
CREATE INDEX client_id_index
    ON clients(id)
    INCLUDE (current_balance);

CREATE UNLOGGED TABLE transactions (
     id SERIAL PRIMARY KEY,
     client_id INT NOT NULL,
     amount INT NOT NULL,
     kind CHAR NOT NULL,
     description VARCHAR(10) NOT NULL,
     submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES clients(id)
);
CREATE INDEX tansaction_id_index ON transactions(id);

INSERT INTO clients VALUES (1, 1000*100), (2, 800*100), (3, 10000*100), (4, 100000*100),(5, 5000*100);

CREATE OR REPLACE FUNCTION new_balance(
    client_id INT,
    kind CHAR,
    amount INT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
    DECLARE current_balance INT;
    BEGIN
        SELECT current_balance INTO current_balance FROM clients WHERE id = client_id;

        CASE kind
            WHEN 'c' THEN
                RETURN current_balance + amount;
            WHEN 'd' THEN
                RETURN current_balance - amount;
            ELSE
                RAISE EXCEPTION 'Tipo de transação inválida';
        END CASE;

    END;
$$;

CREATE OR REPLACE FUNCTION get_transactions(
    cId INT
)
RETURNS TABLE (amount INT, kind CHAR, description VARCHAR(10), submitted_at TIMESTAMP)
LANGUAGE plpgsql
AS $$
   BEGIN
       RETURN QUERY
           SELECT transactions.amount, transactions.kind, transactions.description, transactions.submitted_at
           FROM transactions
           WHERE transactions.client_id = cId;
    END;
$$;

CREATE OR REPLACE PROCEDURE credit(
    client_id INT,
    amount INT,
    description VARCHAR(10),
    OUT res INT
)
LANGUAGE plpgsql
AS $$
    DECLARE new_balance INT;
    BEGIN

        INSERT INTO transactions (client_id, amount, kind, description)
        VALUES (client_id, amount, 'c', description);

        PERFORM pg_advisory_lock(client_id);
        new_balance := new_balance(client_id, 'c', amount);
        UPDATE clients SET current_balance = new_balance WHERE id = client_id;
        PERFORM pg_advisory_unlock(client_id);

        res := new_balance;
    END;
$$;

CREATE OR REPLACE PROCEDURE debit(
    client_id INT,
    amount INT,
    description VARCHAR(10),
    OUT res INT
)
    LANGUAGE plpgsql
AS $$
    DECLARE new_balance INT;
    BEGIN
        INSERT INTO transactions (client_id, amount, kind, description)
        VALUES (client_id, amount, 'd', description);

        PERFORM pg_advisory_lock(client_id);
        new_balance := new_balance(client_id, 'd', amount);
        UPDATE clients SET current_balance = new_balance WHERE id = client_id;
        PERFORM pg_advisory_unlock(client_id);

        res := new_balance;
    END;
$$;




