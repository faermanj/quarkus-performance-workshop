CREATE unlogged TABLE IF NOT EXISTS public.members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50),
	limit INTEGER NOT NULL DEFAULT 0,
	current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE unlogged TABLE IF NOT EXISTS public.transactions (
	id SERIAL PRIMARY KEY,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	cliente_id INTEGER NOT NULL,
	FOREIGN KEY (cliente_id) REFERENCES members (id)
);

create index ix_transacao_cliente_data on transactions(cliente_id, submitted_at desc);

DO $$
BEGIN
  INSERT INTO members (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$