CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE transactions1 (
id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions2 (
id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions3 (
id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions4 (
id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions5 (
id SERIAL PRIMARY KEY,
    current_balance INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE UNLOGGED TABLE current_balances (
	id INTEGER PRIMARY KEY,
	amount INTEGER NOT NULL
);

CREATE OR REPLACE FUNCTION balance1()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT current_balance a, amount b, kind c, description d, submitted_at e FROM transactions1 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance2()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT current_balance a, amount b, kind c, description d, submitted_at e FROM transactions2 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance3()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT current_balance a, amount b, kind c, description d, submitted_at e FROM transactions3 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance4()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT current_balance a, amount b, kind c, description d, submitted_at e FROM transactions4 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance5()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT current_balance a, amount b, kind c, description d, submitted_at e FROM transactions5 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION credito1(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(1);

	UPDATE current_balances SET amount = amount + aa WHERE id = 1 RETURNING amount into cc;
	INSERT INTO transactions1(current_balance, amount, kind, description, submitted_at) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito2(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(2);

	UPDATE current_balances SET amount = amount + aa WHERE id = 2 RETURNING amount into cc;
	INSERT INTO transactions2(current_balance, amount, kind, description, submitted_at) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito3(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(3);

	UPDATE current_balances SET amount = amount + aa WHERE id = 3 RETURNING amount into cc;
	INSERT INTO transactions3(current_balance, amount, kind, description, submitted_at) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito4(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(4);

	UPDATE current_balances SET amount = amount + aa WHERE id = 4 RETURNING amount into cc;
	INSERT INTO transactions4(current_balance, amount, kind, description, submitted_at) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito5(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(5);

	UPDATE current_balances SET amount = amount + aa WHERE id = 5 RETURNING amount into cc;
	INSERT INTO transactions5(current_balance, amount, kind, description, submitted_at) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION debito1(aa INT, b VARCHAR(10), c INT)
RETURNS TABLE (dd INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(1);

	UPDATE current_balances SET amount = amount - aa WHERE id = 1 AND (amount - aa) >= (c * -1) RETURNING amount into dd;
	IF FOUND THEN
		INSERT INTO transactions1(current_balance, amount, kind, description, submitted_at) VALUES (dd, aa, 'd', b, now());
	ELSE
		dd := NULL;
	END IF;

	RETURN QUERY SELECT dd;
END;
$$;

CREATE OR REPLACE FUNCTION debito2(aa INT, b VARCHAR(10), c INT)
RETURNS TABLE (dd INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(2);

	UPDATE current_balances SET amount = amount - aa WHERE id = 2 AND (amount - aa) >= (c * -1) RETURNING amount into dd;
	IF FOUND THEN
		INSERT INTO transactions2(current_balance, amount, kind, description, submitted_at) VALUES (dd, aa, 'd', b, now());
	ELSE
		dd := NULL;
	END IF;

	RETURN QUERY SELECT dd;
END;
$$;

CREATE OR REPLACE FUNCTION debito3(aa INT, b VARCHAR(10), c INT)
RETURNS TABLE (dd INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(3);

	UPDATE current_balances SET amount = amount - aa WHERE id = 3 AND (amount - aa) >= (c * -1) RETURNING amount into dd;
	IF FOUND THEN
		INSERT INTO transactions3(current_balance, amount, kind, description, submitted_at) VALUES (dd, aa, 'd', b, now());
	ELSE
		dd := NULL;
	END IF;

	RETURN QUERY SELECT dd;
END;
$$;

CREATE OR REPLACE FUNCTION debito4(aa INT, b VARCHAR(10), c INT)
RETURNS TABLE (dd INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(4);

	UPDATE current_balances SET amount = amount - aa WHERE id = 4 AND (amount - aa) >= (c * -1) RETURNING amount into dd;
	IF FOUND THEN
		INSERT INTO transactions4(current_balance, amount, kind, description, submitted_at) VALUES (dd, aa, 'd', b, now());
	ELSE
		dd := NULL;
	END IF;

	RETURN QUERY SELECT dd;
END;
$$;

CREATE OR REPLACE FUNCTION debito5(aa INT, b VARCHAR(10), c INT)
RETURNS TABLE (dd INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(5);

	UPDATE current_balances SET amount = amount - aa WHERE id = 5 AND (amount - aa) >= (c * -1) RETURNING amount into dd;
	IF FOUND THEN
		INSERT INTO transactions5(current_balance, amount, kind, description, submitted_at) VALUES (dd, aa, 'd', b, now());
	ELSE
		dd := NULL;
	END IF;

	RETURN QUERY SELECT dd;
END;
$$;

DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);

	INSERT INTO current_balances (id, amount)
		SELECT id, 0 FROM clientes;

--insert into public.transactions1(current_balance, amount, kind, description, submitted_at) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions2(current_balance, amount, kind, description, submitted_at) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions3(current_balance, amount, kind, description, submitted_at) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions4(current_balance, amount, kind, description, submitted_at) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions5(current_balance, amount, kind, description, submitted_at) values (0, 0, 'i', 'inicio', now());

END;
$$;
