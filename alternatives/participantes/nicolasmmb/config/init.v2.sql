CREATE UNLOGGED
TABLE members (
    id SERIAL PRIMARY KEY, nome VARCHAR(50) NOT NULL, limite INTEGER NOT NULL, saldo INTEGER DEFAULT 0
);

CREATE UNLOGGED
TABLE transacoes (
    id SERIAL PRIMARY KEY, cliente_id INTEGER NOT NULL, valor INTEGER NOT NULL, tipo CHAR(1) NOT NULL, descricao VARCHAR(10) NOT NULL, realizada_em TIMESTAMP NOT NULL DEFAULT NOW(), CONSTRAINT fk_members_transacoes_id FOREIGN KEY (cliente_id) REFERENCES members (id)
);

DO $$ 
BEGIN 
	INSERT INTO
	    members (nome, limite, saldo)
	VALUES ('Asuka', 1000 * 100, 0),
	    ('Rin', 5000 * 100, 0),
	    ('Shinji', 800 * 100, 0),
	    ('Fern', 10000 * 100, 0),
	    ('Frienren', 100000 * 100, 0);
END;
$$; 

CREATE INDEX idx_compound_cliente_id_realizado_em ON transacoes (cliente_id, realizada_em);
CREATE INDEX idx_transacoes_cliente_id ON transacoes (cliente_id);
CREATE INDEX idx_members_id ON members (id);