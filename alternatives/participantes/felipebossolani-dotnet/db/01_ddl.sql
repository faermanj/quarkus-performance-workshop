CREATE UNLOGGED TABLE clientes (
    id integer PRIMARY KEY NOT NULL,
    current_balance integer NOT NULL,
    limit integer NOT NULL
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    kind char(1) NOT NULL,
    amount integer NOT NULL,
    description varchar(10) NOT NULL,
    submitted_at timestamp NOT NULL,
    idcliente integer NOT NULL
);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_clientes
FOREIGN KEY (idcliente) REFERENCES clientes(id);

CREATE INDEX ix_transactions_idcliente ON transactions
(
    idcliente ASC
);