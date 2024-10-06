CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    limit BIGINT,
    current_balance_inicial BIGINT
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    amount BIGINT,
    kind CHAR(1),
    description TEXT,
    submitted_at TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO clientes (limit, current_balance_inicial) VALUES
                                                 (100000, 0),
                                                 (80000, 0),
                                                 (1000000, 0),
                                                 (10000000, 0),
                                                 (500000, 0);
