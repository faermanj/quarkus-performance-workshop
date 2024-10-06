CREATE TABLE clientes
(
    id     SERIAL PRIMARY KEY,
    nome   VARCHAR(32),
    limit NUMERIC DEFAULT 0,
    current_balance  NUMERIC DEFAULT 0,
    version NUMERIC DEFAULT 1
);

CREATE TABLE transactions
(
    id         SERIAL PRIMARY KEY,
    cliente_id numeric     NOT NULL,
    kind       char        NOT NULL,
    amount      numeric     NOT NULL,
    description  VARCHAR(10) NOT NULL,
    criado     timestamp DEFAULT NOW()
);


INSERT INTO clientes (nome, limit)
VALUES ('o barato sai caro', 1000 * 100),
       ('zan corp ltda', 800 * 100),
       ('les cruders', 10000 * 100),
       ('padaria joia de cocaia', 100000 * 100),
       ('kid mais', 5000 * 100);
