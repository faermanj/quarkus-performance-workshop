CREATE TABLE clientes
(
    id INT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    limit_conta INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TYPE TipoOperacao AS ENUM('c', 'd');

CREATE TABLE transactions
(
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind TipoOperacao NOT NULL,
    description VARCHAR(10) NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_transactions_client_id
        FOREIGN KEY (cliente_id) REFERENCES clientes (id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);
CREATE INDEX idx_transactions_criado_em ON transactions (criado_em);

INSERT INTO clientes (id, nome, limit_conta)
VALUES
    (1, 'Van Hohenheim', 100000),
    (2, 'Edward Elric', 80000),
    (3, 'Alphonse Elric', 1000000),
    (4, 'Roy Mustang', 10000000),
    (5, 'Winry Rockbell', 500000);

