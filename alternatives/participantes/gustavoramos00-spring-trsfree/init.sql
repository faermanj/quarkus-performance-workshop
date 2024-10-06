CREATE UNLOGGED TABLE cliente (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transacao (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_cliente_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE UNLOGGED TABLE conta (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	current_balance INTEGER NOT NULL,
	limit INTEGER NOT NULL,
	CONSTRAINT fk_cliente_conta_id
		FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

DO $$
BEGIN
	INSERT INTO cliente (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO conta (cliente_id, current_balance, limit)
		SELECT id, 0, limit FROM cliente;
END;
$$;
