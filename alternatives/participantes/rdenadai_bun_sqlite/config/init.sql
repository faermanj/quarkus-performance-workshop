CREATE TABLE members (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE TABLE transactions (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT(STRFTIME('%Y-%m-%d %H:%M:%f', 'NOW')),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE current_balances (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	CONSTRAINT fk_members_current_balances_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

BEGIN TRANSACTION;
	INSERT INTO members (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO current_balances (cliente_id, amount)
        SELECT id, 0 FROM members;
COMMIT;