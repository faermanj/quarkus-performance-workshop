CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX CONCURRENTLY idx_transactions_cliente_id
	ON transactions (cliente_id);

DO $$
BEGIN
	INSERT INTO members (nome, limit, current_balance)
	VALUES
		('o barato sai caro', 1000 * 100, 0),
		('zan corp ltda', 800 * 100, 0),
		('les cruders', 10000 * 100, 0),
		('padaria joia de cocaia', 100000 * 100, 0),
		('kid mais', 5000 * 100, 0);
	
END;
$$;

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS RECORD
LANGUAGE plpgsql
AS $$
DECLARE
	record RECORD;
	_limit int;
	_current_balance int;
 	success int;
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);
	
  UPDATE members
     SET current_balance = current_balance - amount_tx
   WHERE id = cliente_id_tx
     AND ABS(current_balance - amount_tx) <= limit
RETURNING current_balance, limit INTO _current_balance, _limit;

	GET DIAGNOSTICS success = ROW_COUNT;

	IF success THEN
		INSERT INTO transactions (cliente_id, amount, kind, description)
		VALUES (cliente_id_tx, amount_tx, 'd', description_tx);

		SELECT success, _current_balance, _limit INTO record;
  ELSE 
  	SELECT 0, current_balance, limit
      FROM members
     WHERE id = cliente_id_tx
      INTO record;
	END IF;
  
  RETURN record;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	amount_tx INT,
	description_tx VARCHAR(10))
RETURNS TABLE (
	novo_current_balance INT,
	_limit INT)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO transactions
		VALUES(DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

	RETURN QUERY
		UPDATE members
		SET current_balance = current_balance + amount_tx
		WHERE id = cliente_id_tx
		RETURNING current_balance, limit;
END;
$$;
