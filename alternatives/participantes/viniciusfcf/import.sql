CREATE TABLE public.cliente (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL -- poderia ter tirado, n tirei por preguiça
);

CREATE TABLE public.current_balancecliente (
	id INTEGER PRIMARY KEY NOT NULL, -- id do cliente
	-- Dupliquei, é a vida.
	limit INTEGER NOT NULL,
  	current_balance INTEGER NOT NULL
);

CREATE TABLE public.transacao (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL,
	-- Dupliquei, é a vida.
	limit INTEGER NOT NULL,
  	current_balance INTEGER NOT NULL
);

CREATE INDEX transactions_index ON public.transacao (cliente_id, id desc) INCLUDE (amount, kind, description, submitted_at, limit, current_balance);
create sequence Cliente_SEQ start with 1 increment by 50;
INSERT INTO public.cliente (id, limit)
	VALUES
		(1, 1000 * 100),
		(2, 800 * 100),
		(3, 10000 * 100),
		(4, 100000 * 100),
		(5, 5000 * 100);

INSERT INTO public.current_balancecliente (id, limit, current_balance)
	VALUES
		(1, 1000 * 100, 0),
		(2, 800 * 100, 0),
		(3, 10000 * 100, 0),
		(4, 100000 * 100, 0),
		(5, 5000 * 100, 0);
	