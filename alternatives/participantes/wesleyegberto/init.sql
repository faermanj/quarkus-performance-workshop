DROP TABLE IF EXISTS public.members;
DROP TABLE IF EXISTS public.transactions;

CREATE UNLOGGED TABLE members (
	id SERIAL NOT NULL,
	nome VARCHAR(50) NOT NULL,
	limite BIGINT NOT NULL,
	saldo BIGINT NOT NULL DEFAULT 0,
	CONSTRAINT members_pk PRIMARY KEY (id)
);

CREATE INDEX idx_cov_members ON members(id) INCLUDE (limite, saldo);

CREATE UNLOGGED TABLE public.transactions (
	id SERIAL NOT NULL,
	id_cliente INT NOT NULL,
	realizada_em TIMESTAMP NOT NULL,
	tipo CHAR(1) NOT NULL,
	valor BIGINT NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	CONSTRAINT transactions_pk PRIMARY KEY (id),
	CONSTRAINT tipo_permitido CHECK (tipo = 'c' OR tipo = 'd')
);

CREATE INDEX ultimas_transactions_idx ON public.transactions (id_cliente ASC, realizada_em DESC);

-- members iniciais
INSERT INTO public.members (nome, limite)
VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);

