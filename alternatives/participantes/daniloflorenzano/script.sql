-- Coloque scripts iniciais aqui
CREATE TABLE IF NOT EXISTS clientes
(
    id     SERIAL,
    limit INTEGER,
    current_balance  INTEGER DEFAULT 0
);

CREATE UNIQUE INDEX IF NOT EXISTS clientes_id_idx ON clientes (id);

INSERT INTO clientes (limit)
VALUES (1000 * 100),
       (800 * 100),
       (10000 * 100),
       (100000 * 100),
       (5000 * 100);
END;

CREATE TABLE IF NOT EXISTS transactions
(
    id           SERIAL,
    cliente_id   INTEGER,
    amount        INTEGER,
    kind         CHAR(1),
    description    VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS transactions_id_idx ON transactions (id);