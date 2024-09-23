CREATE TABLE members (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	nome VARCHAR(50) NOT NULL,
	limite INTEGER NOT NULL
);

CREATE TABLE transactions (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE saldos (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	CONSTRAINT fk_members_saldos_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

BEGIN TRANSACTION;
	INSERT INTO members (nome, limite)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO saldos (cliente_id, valor)
        SELECT id, 0 FROM members;
COMMIT;