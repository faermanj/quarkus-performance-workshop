CREATE UNLOGGED TABLE cliente (
	user_id SMALLINT PRIMARY KEY,
	limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	user_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (user_id) REFERENCES cliente(user_id)
);

CREATE INDEX idx_cliente_user_id ON cliente (user_id);
CREATE INDEX idx_transactions_user_id ON transactions (user_id);

DO $$
BEGIN
	INSERT INTO cliente (user_id, limit, current_balance)
	VALUES
		(1, 100000, 0),
		(2, 80000, 0),
		(3, 1000000, 0),
		(4, 10000000, 0),
		(5, 500000, 0);
END;
$$;