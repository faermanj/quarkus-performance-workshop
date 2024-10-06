CREATE TABLE clients (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	client_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clients
		FOREIGN KEY (client_id) REFERENCES clients(id)
);

DO $$
BEGIN
    INSERT INTO clients(id, limit, current_balance) 
    VALUES 
        (1,100000,0),
        (2,80000,0),
        (3,1000000,0),
        (4,10000000,0),
        (5,500000,0);
END; 
$$;

CREATE OR REPLACE FUNCTION funcoes(cliente_id int, amount_d int, description VARCHAR(10), kind VARCHAR(1))
    RETURNS int 
    LANGUAGE plpgsql
    as
    $$
    declare 
        s_atual int;
        l_atual int;

    BEGIN 
        PERFORM pg_advisory_xact_lock(cliente_id);
        SELECT
            limit,
            current_balance
        INTO
            l_atual,
            s_atual
        FROM clients WHERE id = cliente_id;

        IF kind = 'd' THEN
            IF s_atual - amount_d >= l_atual * -1 THEN
                INSERT INTO transactions(client_Id,amount,kind,description) VALUES (cliente_id,amount_d,'d',description);
                UPDATE clients SET current_balance = s_atual - amount_d WHERE id = cliente_id;
                RETURN 1;
            ELSE
                RETURN 0;
            END IF;
        ELSE
            INSERT INTO transactions(client_Id,amount,kind,description) VALUES (cliente_id,amount_d,'c',description);
            UPDATE clients SET current_balance = s_atual + amount_d WHERE id = cliente_id;
            RETURN 1;
        END IF;
    END;
    $$;