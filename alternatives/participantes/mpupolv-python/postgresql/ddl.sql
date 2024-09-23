CREATE TYPE tipo_transacao AS ENUM ('c', 'd');
CREATE UNLOGGED TABLE members (
     id serial PRIMARY KEY,
     limite integer NOT NULL,
     saldo integer NOT NULL DEFAULT 0
);
CREATE UNLOGGED TABLE transactions (
     id serial PRIMARY KEY,
     cliente_id integer REFERENCES members(id) NOT NULL,
     tipo tipo_transacao NOT NULL,
     valor integer NOT NULL,
     descricao varchar(40) NOT NULL CHECK (descricao <> ''),
     realizada_em timestamp with time zone DEFAULT current_timestamp
);
CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id ASC);
