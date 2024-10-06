CREATE TABLE members
(
    id     SERIAL PRIMARY KEY,
    nome   VARCHAR(50) NOT NULL,
    limit INTEGER     NOT NULL
);

CREATE TABLE transactions
(
    id           SERIAL PRIMARY KEY,
    cliente_id   INTEGER     NOT NULL,
    amount        INTEGER     NOT NULL,
    kind         CHAR(1)     NOT NULL,
    description    VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP   NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_members_transactions_id
        FOREIGN KEY (cliente_id) REFERENCES members (id)
);

CREATE INDEX i_cliente_submitted_at
    ON transactions (cliente_id, submitted_at);


CREATE TABLE current_balances
(
    id         SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount      INTEGER NOT NULL,
    versao     INTEGER NOT NULL,
    CONSTRAINT fk_members_current_balances_id
        FOREIGN KEY (cliente_id) REFERENCES members (id)
);