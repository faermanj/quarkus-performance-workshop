CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    data_ins TIMESTAMP NOT NULL
);

CREATE INDEX IDX_clientes_id ON clientes (id);
CREATE INDEX IDX_transactions_cliente_id ON transactions (cliente_id);

INSERT INTO clientes (id, limit, current_balance) VALUES (1,100000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (2,80000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (3,1000000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (4,10000000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (5,500000, 0);