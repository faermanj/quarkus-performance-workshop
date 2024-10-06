CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE IF NOT EXISTS clientes (
                                        id SERIAL PRIMARY KEY NOT NULL,
                                        nome VARCHAR(100) NOT NULL,
                                        limit int DEFAULT 0,
                                        current_balance int DEFAULT 0
);

CREATE INDEX IF NOT EXISTS clientes_id ON clientes (id);


INSERT INTO clientes (nome, limit)
VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);

CREATE TABLE IF NOT EXISTS transactions (
                                          id SERIAL PRIMARY KEY,
                                          cliente_id INTEGER NOT NULL,
                                          amount INTEGER NOT NULL,
                                          kind CHAR(1) NOT NULL,
                                          description VARCHAR(10) NOT NULL,
                                          submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                          CONSTRAINT fk_clientes_transactions_id
                                              FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE INDEX IF NOT EXISTS transactions_clientes_id ON transactions (cliente_id);

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE IF NOT EXISTS clientes (
                                        id SERIAL PRIMARY KEY NOT NULL,
                                        nome VARCHAR(100) NOT NULL,
                                        limit int DEFAULT 0,
                                        current_balance int DEFAULT 0
);

CREATE INDEX IF NOT EXISTS clientes_id ON clientes (id);


INSERT INTO clientes (nome, limit)
VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);

CREATE TABLE IF NOT EXISTS transactions (
                                          id SERIAL PRIMARY KEY,
                                          cliente_id INTEGER NOT NULL,
                                          amount INTEGER NOT NULL,
                                          kind CHAR(1) NOT NULL,
                                          description VARCHAR(10) NOT NULL,
                                          submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
                                          CONSTRAINT fk_clientes_transactions_id
                                              FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE INDEX IF NOT EXISTS transactions_clientes_id ON transactions (cliente_id);

