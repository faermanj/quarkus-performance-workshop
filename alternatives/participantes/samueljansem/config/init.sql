SET CLIENT_MIN_MESSAGES = WARNING;
SET ROW_SECURITY = OFF;

CREATE UNLOGGED TABLE
    "members" (
        "id" INT PRIMARY KEY,
        "saldo" INTEGER NOT NULL,
        "limite" INTEGER NOT NULL
    );

CREATE INDEX idx_pk_members ON members (id) INCLUDE (saldo);
CLUSTER members USING idx_pk_members;

CREATE UNLOGGED TABLE
    "transactions" (
        "id" SERIAL PRIMARY KEY,
        "valor" INTEGER NOT NULL,
        "id_cliente" INTEGER NOT NULL,
        "tipo" VARCHAR(1) NOT NULL,
        "descricao" VARCHAR(10) NOT NULL,
        "realizada_em" TIMESTAMP WITH TIME ZONE NOT NULL,
        CONSTRAINT "fk_transactions_id_cliente" FOREIGN KEY ("id_cliente") REFERENCES "members" ("id")
    );

CREATE INDEX idx_transactions_id_cliente ON transactions (id_cliente);
CREATE INDEX idx_transactions_realizada_em ON transactions (realizada_em DESC);
CLUSTER transactions USING idx_transactions_id_cliente;


ALTER TABLE "members" SET (autovacuum_enabled = false);
ALTER TABLE "transactions" SET (autovacuum_enabled = false);

INSERT INTO
    members (id, saldo, limite)
VALUES
    (1, 0, 100000),
    (2, 0, 80000),
    (3, 0, 1000000),
    (4, 0, 10000000),
    (5, 0, 500000);

CREATE OR REPLACE PROCEDURE criar_transacao_e_atualizar_saldo(
    id_cliente INTEGER,
    valor INTEGER,
    tipo VARCHAR(1),
    descricao VARCHAR(10),
    realizada_em TIMESTAMP WITH TIME ZONE,
    INOUT saldo_atual INTEGER DEFAULT NULL,
    INOUT limite_atual INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    valor_absoluto INTEGER;
BEGIN
    valor_absoluto := valor;

    IF tipo = 'd' THEN
        valor := -valor;
    END IF;

    UPDATE members
    SET saldo = saldo + valor
    WHERE id = id_cliente AND (saldo + valor) >= -limite
    RETURNING saldo, limite INTO saldo_atual, limite_atual;

    INSERT INTO transactions (valor, id_cliente, tipo, descricao, realizada_em)
    VALUES (valor_absoluto, id_cliente, tipo, descricao, realizada_em);
END;
$$;
