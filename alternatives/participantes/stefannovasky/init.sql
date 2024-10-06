CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL, -- nem precisa mas ta aí
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX ix_transactions_cliente_id_submitted_at ON transactions (cliente_id, submitted_at DESC);

CREATE FUNCTION debito(cliente_id INTEGER, amount_transacao INTEGER, description_transacao TEXT)
RETURNS SETOF INTEGER -- retorna current_balance do cliente apos a transacao
LANGUAGE plpgsql
AS $BODY$
	DECLARE cliente_novo_current_balance INTEGER;
	DECLARE cliente_limit INTEGER;
BEGIN
	SELECT
		current_balance - amount_transacao,
		limit
	INTO cliente_novo_current_balance, cliente_limit
	FROM members
	WHERE id = cliente_id
	FOR UPDATE;

	IF cliente_novo_current_balance < (-cliente_limit) THEN RETURN; END IF;

	INSERT INTO transactions (cliente_id, amount, kind, description)
	VALUES (cliente_id, amount_transacao, 'd', description_transacao);

	RETURN QUERY
	UPDATE members
	SET current_balance = cliente_novo_current_balance
	WHERE id = cliente_id
	RETURNING current_balance;
END;
$BODY$;

CREATE FUNCTION credito(cliente_id INTEGER, amount_transacao INTEGER, description_transacao TEXT)
RETURNS SETOF INTEGER -- retorna current_balance do cliente apos a transacao
LANGUAGE plpgsql
AS $BODY$
	DECLARE cliente_novo_current_balance INTEGER;
BEGIN
	INSERT INTO transactions (cliente_id, amount, kind, description)
	VALUES (cliente_id, amount_transacao, 'c', description_transacao);

	RETURN QUERY
	UPDATE members
	SET current_balance = current_balance + amount_transacao
	WHERE id = cliente_id
	RETURNING current_balance;
END;
$BODY$;

INSERT INTO members (nome, limit) values
	('eh', 1000 * 100),
	('os', 800 * 100),
	('guri', 10000 * 100),
	('nao tem', 100000 * 100),
	('jeito', 5000 * 100);
