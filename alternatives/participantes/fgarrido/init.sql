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
	limit INTEGER NOT NULL,
	amount INTEGER NOT NULL
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);
CREATE INDEX idx_current_balances_cliente_id ON current_balances (cliente_id);

DO $$
BEGIN
	INSERT INTO current_balances (cliente_id, limit, amount)
	VALUES (1,   100000, 0),
		   (2,    80000, 0),
		   (3,  1000000, 0),
		   (4, 10000000, 0),
		   (5,   500000, 0);
END;
$$;
