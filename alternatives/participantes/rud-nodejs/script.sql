CREATE UNLOGGED TABLE members (
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
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE UNLOGGED TABLE saldos (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	CONSTRAINT fk_members_saldos_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

DO $$
BEGIN
	INSERT INTO members (nome, limite)
	VALUES
		('batata1', 1000 * 100),
		('batata2', 800 * 100),
		('batata3', 10000 * 100),
		('batata4', 100000 * 100),
		('batata5', 5000 * 100);
	
	INSERT INTO saldos (cliente_id, valor)
		SELECT id, 0 FROM members;
END;
$$;