CREATE UNLOGGED TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limite INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE transactions1 (
id SERIAL PRIMARY KEY,
    saldo INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions2 (
id SERIAL PRIMARY KEY,
    saldo INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions3 (
id SERIAL PRIMARY KEY,
    saldo INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions4 (
id SERIAL PRIMARY KEY,
    saldo INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE TABLE transactions5 (
id SERIAL PRIMARY KEY,
    saldo INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE UNLOGGED TABLE saldos (
	id INTEGER PRIMARY KEY,
	valor INTEGER NOT NULL
);

CREATE OR REPLACE FUNCTION balance1()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT saldo a, valor b, tipo c, descricao d, realizada_em e FROM transactions1 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance2()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT saldo a, valor b, tipo c, descricao d, realizada_em e FROM transactions2 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance3()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT saldo a, valor b, tipo c, descricao d, realizada_em e FROM transactions3 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance4()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT saldo a, valor b, tipo c, descricao d, realizada_em e FROM transactions4 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION balance5()
RETURNS TABLE (a INTEGER, b INTEGER, c character(1), d VARCHAR, e TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT saldo a, valor b, tipo c, descricao d, realizada_em e FROM transactions5 order by id desc limit 10;
END;
$$;

CREATE OR REPLACE FUNCTION credito1(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(1);

	UPDATE saldos SET valor = valor + aa WHERE id = 1 RETURNING valor into cc;
	INSERT INTO transactions1(saldo, valor, tipo, descricao, realizada_em) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito2(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(2);

	UPDATE saldos SET valor = valor + aa WHERE id = 2 RETURNING valor into cc;
	INSERT INTO transactions2(saldo, valor, tipo, descricao, realizada_em) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito3(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(3);

	UPDATE saldos SET valor = valor + aa WHERE id = 3 RETURNING valor into cc;
	INSERT INTO transactions3(saldo, valor, tipo, descricao, realizada_em) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito4(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(4);

	UPDATE saldos SET valor = valor + aa WHERE id = 4 RETURNING valor into cc;
	INSERT INTO transactions4(saldo, valor, tipo, descricao, realizada_em) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION credito5(aa INT, b VARCHAR(10))
RETURNS TABLE (cc INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(5);

	UPDATE saldos SET valor = valor + aa WHERE id = 5 RETURNING valor into cc;
	INSERT INTO transactions5(saldo, valor, tipo, descricao, realizada_em) VALUES (cc, aa, 'c', b, now());

	RETURN QUERY SELECT cc;
END;
$$;

CREATE OR REPLACE FUNCTION debito1(aa INT, b VARCHAR(10), c INT)
RETURNS TABLE (dd INT)
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(1);

	UPDATE saldos SET valor = valor - aa WHERE id = 1 AND (valor - aa) >= (c * -1) RETURNING valor into dd;
	IF FOUND THEN
		INSERT INTO transactions1(saldo, valor, tipo, descricao, realizada_em) VALUES (dd, aa, 'd', b, now());
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

	UPDATE saldos SET valor = valor - aa WHERE id = 2 AND (valor - aa) >= (c * -1) RETURNING valor into dd;
	IF FOUND THEN
		INSERT INTO transactions2(saldo, valor, tipo, descricao, realizada_em) VALUES (dd, aa, 'd', b, now());
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

	UPDATE saldos SET valor = valor - aa WHERE id = 3 AND (valor - aa) >= (c * -1) RETURNING valor into dd;
	IF FOUND THEN
		INSERT INTO transactions3(saldo, valor, tipo, descricao, realizada_em) VALUES (dd, aa, 'd', b, now());
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

	UPDATE saldos SET valor = valor - aa WHERE id = 4 AND (valor - aa) >= (c * -1) RETURNING valor into dd;
	IF FOUND THEN
		INSERT INTO transactions4(saldo, valor, tipo, descricao, realizada_em) VALUES (dd, aa, 'd', b, now());
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

	UPDATE saldos SET valor = valor - aa WHERE id = 5 AND (valor - aa) >= (c * -1) RETURNING valor into dd;
	IF FOUND THEN
		INSERT INTO transactions5(saldo, valor, tipo, descricao, realizada_em) VALUES (dd, aa, 'd', b, now());
	ELSE
		dd := NULL;
	END IF;

	RETURN QUERY SELECT dd;
END;
$$;

DO $$
BEGIN
	INSERT INTO clientes (nome, limite)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);

	INSERT INTO saldos (id, valor)
		SELECT id, 0 FROM clientes;

--insert into public.transactions1(saldo, valor, tipo, descricao, realizada_em) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions2(saldo, valor, tipo, descricao, realizada_em) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions3(saldo, valor, tipo, descricao, realizada_em) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions4(saldo, valor, tipo, descricao, realizada_em) values (0, 0, 'i', 'inicio', now());
--insert into public.transactions5(saldo, valor, tipo, descricao, realizada_em) values (0, 0, 'i', 'inicio', now());

END;
$$;
