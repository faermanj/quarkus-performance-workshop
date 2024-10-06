CREATE UNLOGGED  TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER  NOT NULL
);

CREATE UNLOGGED  TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX transactions_cliente_id_idx ON transactions (cliente_id);
-- CREATE INDEX cliente_id_idx ON members (id) include (limit, current_balance);



CREATE OR REPLACE FUNCTION public.update_current_balance_cliente(p_cliente_id integer, p_amount bigint, p_kind character varying, p_description character varying)
 RETURNS TABLE(new_current_balance integer, limit integer, erro character varying)
 LANGUAGE plpgsql
AS $function$
DECLARE
  current_balance INTEGER;
  limit INTEGER;
  new_current_balance INTEGER;
  erro character varying;
BEGIN
  SELECT c.current_balance, c.limit INTO current_balance, limit
  FROM members c
  WHERE c.id = p_cliente_id FOR UPDATE;
 
  IF NOT FOUND THEN
    erro = 'P0002';
    RETURN QUERY SELECT current_balance, limit, erro;
    return;
  END IF;

  IF p_kind = 'd' THEN
    new_current_balance := current_balance - p_amount;
    IF new_current_balance + limit < 0 THEN
     erro = 'P0001';
     RETURN QUERY SELECT current_balance, limit, erro;
     return;
    END IF;
  ELSE
    new_current_balance := current_balance + p_amount;
  END IF;

  UPDATE members c SET current_balance = new_current_balance WHERE c.id = p_cliente_id;

  INSERT INTO transactions (cliente_id, kind, amount, description, submitted_at)
  VALUES (
    p_cliente_id,
    p_kind,
    p_amount,
    p_description,
    CURRENT_TIMESTAMP
  );

  RETURN QUERY SELECT new_current_balance, limit, erro;
END;
$function$
;






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

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
SELECT pg_prewarm('transactions');

