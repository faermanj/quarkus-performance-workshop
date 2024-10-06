CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE UNLOGGED TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL
);

CREATE INDEX transactions_idx ON transactions(cliente_id) INCLUDE (amount, kind, description, submitted_at);

DO $$
BEGIN
	INSERT INTO current_balances (cliente_id, amount)
	VALUES
		(1,0),
		(2,0),
		(3,0),
		(4,0),
		(5,0);

END;
$$;
