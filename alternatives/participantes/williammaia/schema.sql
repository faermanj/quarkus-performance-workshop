CREATE TABLE members
(
    id      INT PRIMARY KEY,
    limit  INTEGER     NOT NULL
);
CREATE INDEX id_cliente ON members USING HASH (id);

INSERT INTO members (id, limit)
VALUES  (1, 100000),
        (2, 80000),
        (3, 1000000),
        (4, 10000000),
        (5, 500000);

CREATE TABLE current_balances
(
    cliente_id  INTEGER     NOT NULL,
    balanco     INTEGER     NOT NULL DEFAULT 0,
    limit      INTEGER     NOT NULL DEFAULT 0,
    criado_em   TIMESTAMP   NOT NULL DEFAULT NOW(),
    CHECK (balanco >= (limit * -1))
);
CREATE INDEX current_balances_cliente_id_idx ON public.current_balances USING btree (cliente_id, criado_em DESC);

INSERT INTO current_balances (cliente_id, limit)
SELECT id, limit FROM members;

CREATE TABLE transactions
(
    cliente_id  INTEGER     NOT NULL,
    amount       INTEGER     NOT NULL,
    operacao    CHAR(1)     NOT NULL,
    description   VARCHAR(10) NOT NULL,
    criado_em   TIMESTAMP   NOT NULL DEFAULT NOW()
);
CREATE INDEX transactions_cliente_id_idx ON public.transactions (cliente_id,criado_em DESC);

CREATE USER api01 WITH PASSWORD 'api01_pass';
CREATE USER api02 WITH PASSWORD 'api02_pass';

GRANT ALL ON DATABASE rinha_db TO api01;
GRANT ALL ON ALL TABLES IN SCHEMA public TO api01;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO api01;

GRANT ALL ON DATABASE rinha_db TO api02;
GRANT ALL ON ALL TABLES IN SCHEMA public TO api02;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO api02;
