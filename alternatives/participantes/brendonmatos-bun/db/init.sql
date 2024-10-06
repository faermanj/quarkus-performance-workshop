CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    saldo INTEGER NOT NULL,
    transactions TEXT NOT NULL DEFAULT '[]'
);

CREATE UNIQUE INDEX idx_clientes_id ON clientes USING btree (id);

INSERT INTO clientes (limit, saldo)
VALUES
    (100000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);