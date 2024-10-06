-- Drop tables and recreate them

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clientes;

CREATE UNLOGGED TABLE clientes (
    id integer PRIMARY KEY,
    nome varchar(100),
    limit int,
    current_balance int
);

-- CREATE INDEX idx_clientes_id ON clientes (id);
-- CREATE INDEX idx_clientes_current_balance ON clientes (current_balance);
-- CREATE INDEX idx_clientes_limit ON clientes (limit);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    clienteid integer,
    clientenome varchar(100),
    amount int,
    kind char(1),
    description varchar(10),
    datahora timestamp DEFAULT CURRENT_TIMESTAMP,
    ultimolimit int,
    ultimocurrent_balance int
);

-- CREATE INDEX idx_transactions_id ON transactions (id DESC);
CREATE INDEX idx_transactions_clienteid ON transactions (clienteid);

INSERT INTO clientes (id, nome, limit, current_balance)
  VALUES
    (1, 'o barato sai caro', 1000 * 100, 0),
    (2, 'zan corp ltda', 800 * 100, 0),
    (3, 'les cruders', 10000 * 100, 0),
    (4, 'padaria joia de cocaia', 100000 * 100, 0),
    (5, 'kid mais', 5000 * 100, 0);

INSERT INTO transactions (clienteid, amount, kind, description, clientenome, ultimolimit, ultimocurrent_balance)
  SELECT id, 0, 'c', 'inicial', nome, limit, current_balance FROM clientes;