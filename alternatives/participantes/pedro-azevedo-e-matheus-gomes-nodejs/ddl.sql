CREATE unlogged TABLE IF NOT EXISTS public.members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50),
	limite INTEGER NOT NULL DEFAULT 0,
	saldo INTEGER NOT NULL DEFAULT 0
);

CREATE unlogged TABLE IF NOT EXISTS public.transacoes (
	id SERIAL PRIMARY KEY,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	cliente_id INTEGER NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES members (id)
);

create index ix_transacao_cliente_data on transacoes(cliente_id, realizada_em desc);

DO $$
BEGIN
  INSERT INTO members (nome, limite)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$