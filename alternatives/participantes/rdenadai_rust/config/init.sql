CREATE TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	CONSTRAINT fk_members_current_balances_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TYPE current_balance_result AS (
	efetuado boolean,
    limit integer,
    current_balance integer
);

CREATE OR REPLACE FUNCTION atualiza_current_balance(uclient_id integer, uamount integer, ukind char, udescription varchar) RETURNS current_balance_result AS $$
DECLARE
	ctotal integer;
	climit integer;
	novo_current_balance integer;
	limit integer;
	current_balance integer;
	result current_balance_result;
BEGIN
	result.efetuado := false;

	SELECT c.limit as limit, s.amount as total
	INTO climit, ctotal
	FROM members c 
	JOIN current_balances s on c.id = s.cliente_id 
	WHERE c.id = uclient_id FOR UPDATE;
	
	IF ukind = 'd' THEN
		novo_current_balance := ctotal - uamount;
		IF novo_current_balance < -climit THEN
			result.efetuado := true;
		END IF;
	ELSE
		novo_current_balance := ctotal + uamount;
	END IF;

	IF result.efetuado = false THEN
		UPDATE current_balances SET amount = novo_current_balance WHERE cliente_id = uclient_id;
		INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (uclient_id, uamount, ukind, udescription);
	END IF;

	result.limit := climit;
    result.current_balance := novo_current_balance;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
	INSERT INTO members (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO current_balances (cliente_id, amount)
		SELECT id, 0 FROM members;
END;
$$;