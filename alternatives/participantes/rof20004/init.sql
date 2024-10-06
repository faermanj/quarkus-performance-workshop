CREATE TABLE IF NOT EXISTS members(
    id     BIGSERIAL PRIMARY KEY,
    limit BIGINT NOT NULL,
    current_balance  BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS transactions(
    id           BIGSERIAL PRIMARY KEY,
    cliente_id   BIGINT NOT NULL,
    amount        BIGINT NOT NULL,
    kind         CHAR(1) NOT NULL,
    description    VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE IF NOT EXISTS current_balances(
    id         BIGSERIAL PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    amount      BIGINT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX IF NOT EXISTS members_id_idx ON members(id);
CREATE INDEX IF NOT EXISTS transactions_cliente_id_idx ON transactions(cliente_id);
CREATE INDEX IF NOT EXISTS transactions_submitted_at_idx ON transactions(submitted_at);
CREATE INDEX IF NOT EXISTS current_balances_cliente_id_idx ON current_balances(cliente_id);

INSERT INTO members(limit) VALUES (100000);
INSERT INTO members(limit) VALUES (80000);
INSERT INTO members(limit) VALUES (1000000);
INSERT INTO members(limit) VALUES (10000000);
INSERT INTO members(limit) VALUES (500000);

INSERT INTO current_balances(cliente_id, amount) SELECT id, 0 FROM members;
