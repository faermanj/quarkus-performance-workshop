CREATE UNLOGGED TABLE clientes (
    id integer PRIMARY KEY,
    limit integer NOT NULL,
    current_balance integer NOT NULL
);

INSERT INTO clientes (id, current_balance, limit)
VALUES
  (1, 0, 1000 * 100),
  (2, 0, 800 * 100),
  (3, 0, 10000 * 100),
  (4, 0, 100000 * 100),
  (5, 0, 5000 * 100);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id int NOT NULL,
    amount integer NOT NULL,
    description text,
    data timestamp without time zone default (now() at time zone 'utc')
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id ASC);
CREATE INDEX idx_transactions_data ON transactions (data DESC);
