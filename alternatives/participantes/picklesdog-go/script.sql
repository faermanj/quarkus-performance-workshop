SET idle_in_transaction_session_timeout = 0;
SET check_function_bodies = false;
SET statement_timeout = 0;
SET lock_timeout = 0;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS members;
DROP FUNCTION IF EXISTS CREATE_TRANSACATION;

CREATE UNLOGGED TABLE members (
    id INTEGER NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER CHECK((limit * -1) <= current_balance) NOT NULL
);

CREATE UNLOGGED TABLE transactions (
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    description VARCHAR(10) NOT NULL,
    data TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cliente_transacao ON transactions(cliente_id);
CREATE INDEX idx_transacao_data ON transactions(DATA DESC);

CREATE OR REPLACE FUNCTION CREATE_TRANSACATION(customer_id INTEGER, amount INTEGER, description VARCHAR(10)) RETURNS RECORD AS $$
DECLARE 
	ret RECORD;
BEGIN
				
	UPDATE members 
	SET 
		current_balance = current_balance + amount
	WHERE 
		id = (SELECT id FROM members WHERE id = customer_id FOR UPDATE)
	RETURNING current_balance, limit, 0 INTO ret;
	
	IF ret IS NULL THEN
		RAISE EXCEPTION '-1';
	END IF;

	INSERT 
		INTO transactions (cliente_id, amount, description)
	VALUES
		(customer_id, amount, description);

	RETURN ret;
EXCEPTION WHEN OTHERS THEN
	SELECT 0, 0, SQLERRM INTO ret;
	RETURN ret;
END;$$
LANGUAGE plpgsql;


INSERT INTO members VALUES(1, 100000, 0);
INSERT INTO members VALUES(2, 80000, 0);
INSERT INTO members VALUES(3, 1000000, 0);
INSERT INTO members VALUES(4, 10000000, 0);
INSERT INTO members VALUES(5, 500000, 0);