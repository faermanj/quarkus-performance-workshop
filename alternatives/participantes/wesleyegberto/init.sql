DROP TABLE IF EXISTS public.members;
DROP TABLE IF EXISTS public.transactions;

CREATE UNLOGGED TABLE members (
	id SERIAL NOT NULL,
	nome VARCHAR(50) NOT NULL,
	limit BIGINT NOT NULL,
	current_balance BIGINT NOT NULL DEFAULT 0,
	CONSTRAINT members_pk PRIMARY KEY (id)
);

CREATE INDEX idx_cov_members ON members(id) INCLUDE (limit, current_balance);

CREATE UNLOGGED TABLE public.transactions (
	id SERIAL NOT NULL,
	id_cliente INT NOT NULL,
	submitted_at TIMESTAMP NOT NULL,
	kind CHAR(1) NOT NULL,
	amount BIGINT NOT NULL,
	description VARCHAR(10) NOT NULL,
	CONSTRAINT transactions_pk PRIMARY KEY (id),
	CONSTRAINT kind_permitido CHECK (kind = 'c' OR kind = 'd')
);

CREATE INDEX recent_transactions_idx ON public.transactions (id_cliente ASC, submitted_at DESC);

-- members iniciais
INSERT INTO public.members (nome, limit)
VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);

