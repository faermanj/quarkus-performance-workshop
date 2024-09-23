CREATE TABLE IF NOT EXISTS members(
    id     BIGSERIAL PRIMARY KEY,
    limite BIGINT NOT NULL,
    saldo  BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS transactions(
    id           BIGSERIAL PRIMARY KEY,
    cliente_id   BIGINT NOT NULL,
    valor        BIGINT NOT NULL,
    tipo         CHAR(1) NOT NULL,
    descricao    VARCHAR(10) NOT NULL,
    realizada_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE IF NOT EXISTS saldos(
    id         BIGSERIAL PRIMARY KEY,
    cliente_id BIGINT NOT NULL,
    valor      BIGINT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX IF NOT EXISTS members_id_idx ON members(id);
CREATE INDEX IF NOT EXISTS transactions_cliente_id_idx ON transactions(cliente_id);
CREATE INDEX IF NOT EXISTS transactions_realizada_em_idx ON transactions(realizada_em);
CREATE INDEX IF NOT EXISTS saldos_cliente_id_idx ON saldos(cliente_id);

INSERT INTO members(limite) VALUES (100000);
INSERT INTO members(limite) VALUES (80000);
INSERT INTO members(limite) VALUES (1000000);
INSERT INTO members(limite) VALUES (10000000);
INSERT INTO members(limite) VALUES (500000);

INSERT INTO saldos(cliente_id, valor) SELECT id, 0 FROM members;
