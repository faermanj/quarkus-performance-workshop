CREATE UNLOGGED
TABLE members (
    id SERIAL PRIMARY KEY, nome VARCHAR(50) NOT NULL, limit INTEGER NOT NULL, current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED
TABLE transactions (
    id SERIAL PRIMARY KEY, cliente_id INTEGER NOT NULL, amount INTEGER NOT NULL, kind CHAR(1) NOT NULL, description VARCHAR(10) NOT NULL, submitted_at TIMESTAMP NOT NULL DEFAULT NOW(), CONSTRAINT fk_members_transactions_id FOREIGN KEY (cliente_id) REFERENCES members (id)
);

DO $$ 
BEGIN 
	INSERT INTO
	    members (nome, limit, current_balance)
	VALUES ('Asuka', 1000 * 100, 0),
	    ('Rin', 5000 * 100, 0),
	    ('Shinji', 800 * 100, 0),
	    ('Fern', 10000 * 100, 0),
	    ('Frienren', 100000 * 100, 0);
END;
$$; 

CREATE INDEX idx_compound_cliente_id_realizado_em ON transactions (cliente_id, submitted_at);
CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);
CREATE INDEX idx_members_id ON members (id);