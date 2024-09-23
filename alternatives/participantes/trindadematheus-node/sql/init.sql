CREATE UNLOGGED TABLE members (
    id SERIAL PRIMARY KEY,
    limite INTEGER NOT NULL,
    saldo INTEGER NOT NULL,
    transacoes TEXT NOT NULL DEFAULT '[]'
);

CREATE UNIQUE INDEX idx_members_id ON members USING btree (id);

INSERT INTO members (limite, saldo)
VALUES
    (100000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);