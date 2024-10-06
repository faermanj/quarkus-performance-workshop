
CREATE UNLOGGED TABLE cliente (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(100) NOT NULL,
	limit INTEGER NOT NULL DEFAULT 0,
	current_balance INTEGER NOT NULL DEFAULT 0
);

-- Verificar índices cliente

CREATE UNLOGGED TABLE transacao (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL DEFAULT 0,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	limit_atual INTEGER, -- somente para performance no retorno
	current_balance_atual INTEGER -- somente para performance no retorno
);

CREATE INDEX idx_transacao_cliente_id ON transacao (cliente_id);

INSERT INTO cliente (nome, limit)
VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);

-- Insere amountes iniciais
INSERT INTO transacao (cliente_id, amount, kind, description, limit_atual, current_balance_atual)
  SELECT id, 0, 'i', 'inicial', limit, current_balance
  FROM cliente;
  
