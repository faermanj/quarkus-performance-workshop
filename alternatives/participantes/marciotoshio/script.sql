\c rinha

CREATE TABLE clientes (
    id     SMALLSERIAL PRIMARY KEY,
    limit INTEGER,
    current_balance  INTEGER CHECK (current_balance >= -limit) NOT NULL
);
CREATE INDEX idx_clientes_id ON clientes (id);

CREATE TABLE transactions (
    id           SERIAL PRIMARY KEY,
    amount        INTEGER,
    kind         CHAR(1),
    description    VARCHAR(10),
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cliente_id   SMALLINT REFERENCES clientes (id),
    CONSTRAINT fk_transactions_clientes FOREIGN KEY (cliente_id) REFERENCES clientes (id)
);
CREATE INDEX idx_transactions_cliente_id_submitted_at ON transactions (cliente_id, submitted_at);

INSERT INTO clientes (limit, current_balance)
VALUES
    (100000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (500000, 0);
