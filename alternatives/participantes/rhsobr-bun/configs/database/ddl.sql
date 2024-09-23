CREATE UNLOGGED TABLE members (
    id SERIAL PRIMARY KEY,
    limite INTEGER NOT NULL,
    saldo INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transacoes (
    cliente_id INTEGER NOT NULL,
    valor INTEGER NOT NULL,
    tipo CHAR(1) NOT NULL,
    descricao VARCHAR(10) NOT NULL,
    realizada_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE
    transacoes
ADD
    CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES members (id),
SET
    (autovacuum_enabled = off);

CREATE INDEX IF NOT EXISTS idx_members_id ON members (id);

CREATE INDEX IF NOT EXISTS idx_transacoes_cliente_id_realizada_em_desc ON transacoes (cliente_id, realizada_em DESC);