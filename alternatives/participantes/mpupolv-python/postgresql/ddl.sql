CREATE TYPE kind_transacao AS ENUM ('c', 'd');
CREATE UNLOGGED TABLE members (
     id serial PRIMARY KEY,
     limit integer NOT NULL,
     current_balance integer NOT NULL DEFAULT 0
);
CREATE UNLOGGED TABLE transactions (
     id serial PRIMARY KEY,
     cliente_id integer REFERENCES members(id) NOT NULL,
     kind kind_transacao NOT NULL,
     amount integer NOT NULL,
     description varchar(40) NOT NULL CHECK (description <> ''),
     submitted_at timestamp with time zone DEFAULT current_timestamp
);
CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id ASC);
