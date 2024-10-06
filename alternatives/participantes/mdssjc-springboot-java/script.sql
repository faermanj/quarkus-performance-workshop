CREATE UNLOGGED TABLE IF NOT EXISTS members
(
    id     SERIAL PRIMARY KEY,
    nome   VARCHAR(22) NOT NULL,
    limit INTEGER     NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions
(
    id           SERIAL8 PRIMARY KEY,
    cliente_id   INTEGER     NOT NULL,
    amount        INTEGER     NOT NULL,
    kind         CHAR(1)     NOT NULL,
    description    VARCHAR(10) NOT NULL,
    current_balance        INTEGER     NOT NULL,
    submitted_at TIMESTAMP   NOT NULL,

    FOREIGN KEY (cliente_id) REFERENCES members (id)
);

CREATE INDEX IF NOT EXISTS idx_transactions_cliente_id ON transactions (cliente_id);

DO
$$
    BEGIN
        INSERT INTO members (nome, limit)
        VALUES ('o barato sai caro', 1000 * 100),
               ('zan corp ltda', 800 * 100),
               ('les cruders', 10000 * 100),
               ('padaria joia de cocaia', 100000 * 100),
               ('kid mais', 5000 * 100);
    END;
$$
