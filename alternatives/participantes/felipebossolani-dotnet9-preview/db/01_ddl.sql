CREATE UNLOGGED TABLE clientes (
    id integer PRIMARY KEY NOT NULL,
    saldo integer NOT NULL,
    limite integer NOT NULL
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    tipo char(1) NOT NULL,
    valor integer NOT NULL,
    descricao varchar(10) NOT NULL,
    realizada_em timestamp NOT NULL,
    idcliente integer NOT NULL
);

ALTER TABLE transactions
ADD CONSTRAINT fk_transactions_clientes
FOREIGN KEY (idcliente) REFERENCES clientes(id);

CREATE INDEX ix_transactions_idcliente ON transactions
(
    idcliente ASC
);