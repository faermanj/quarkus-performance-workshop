CREATE UNLOGGED TABLE TRANSACAO (
    "id" SERIAL PRIMARY KEY,
    "submitted_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    "kind" VARCHAR(1) NOT NULL,
    "description" VARCHAR(10) NOT NULL,
    "amount" INTEGER NOT NULL,
    "id_cliente" INTEGER NOT NULL
);

CREATE INDEX CONCURRENTLY IF NOT EXISTS "ID_CLIENT_INDEX" ON TRANSACAO ("id_cliente");
CREATE INDEX CONCURRENTLY IF NOT EXISTS "REALIZADA_EM_INDEX" ON TRANSACAO ("submitted_at" DESC);

CREATE UNLOGGED TABLE USUARIO (
    "id_cliente" INTEGER PRIMARY KEY,
    "limit" INTEGER NOT NULL,
    "current_balance" INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX CONCURRENTLY IF NOT EXISTS "PK_ID_CLIENT_SALDO_INDEX" ON USUARIO ("id_cliente") INCLUDE ("current_balance");

ALTER TABLE TRANSACAO ADD CONSTRAINT "FKEY_TRANSACAO_ID_CLIENT" FOREIGN KEY ("id_cliente") REFERENCES USUARIO("id_cliente");

DO $$
BEGIN
    INSERT INTO USUARIO ("id_cliente", "limit", "current_balance") VALUES (1, 100000, 0);
    INSERT INTO USUARIO ("id_cliente", "limit", "current_balance") VALUES (2, 80000, 0);
    INSERT INTO USUARIO ("id_cliente", "limit", "current_balance") VALUES (3, 1000000, 0);
    INSERT INTO USUARIO ("id_cliente", "limit", "current_balance") VALUES (4, 10000000, 0);
    INSERT INTO USUARIO ("id_cliente", "limit", "current_balance") VALUES (5, 500000, 0);
END $$;

CREATE OR REPLACE FUNCTION ADD_CREDIT_TRANSACTION(
    FC_CLIENT_ID INTEGER, 
    FC_VALOR INTEGER, 
    FC_DESCRICAO VARCHAR(10), 
    OUT FC_SALDO_ATT INTEGER
)
AS $$
BEGIN
    INSERT INTO TRANSACAO (kind, description, amount, id_cliente) 
    VALUES ('c', FC_DESCRICAO, FC_VALOR, FC_CLIENT_ID);

    PERFORM pg_advisory_xact_lock(FC_CLIENT_ID);

    UPDATE USUARIO 
    SET current_balance = current_balance + FC_VALOR 
    WHERE id_cliente = FC_CLIENT_ID
    RETURNING current_balance INTO FC_SALDO_ATT;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ADD_DEBIT_TRANSACTION(
    FC_CLIENT_ID INTEGER, 
    FC_VALOR INTEGER, 
    FC_DESCRICAO VARCHAR(10),
    FC_LIMITE INTEGER,
    OUT FC_SALDO_ATT INTEGER
)
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(FC_CLIENT_ID);

    UPDATE USUARIO
    SET current_balance = current_balance - FC_VALOR 
    WHERE id_cliente = FC_CLIENT_ID AND FC_LIMITE + (current_balance - FC_VALOR) >= 0
    RETURNING current_balance INTO FC_SALDO_ATT;

    IF FC_SALDO_ATT IS NULL THEN
        RETURN;
    END IF;

    INSERT INTO TRANSACAO (kind, description, amount, id_cliente) 
    VALUES ('d', FC_DESCRICAO, FC_VALOR, FC_CLIENT_ID);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION LIST_BANK_STATEMENT(
    FC_CLIENT_ID INTEGER
)
RETURNS TABLE (
    id_cliente INTEGER,
    limit INTEGER,
    current_balance INTEGER,
    submitted_at TIMESTAMP WITH TIME ZONE,
    kind VARCHAR,
    description VARCHAR,
    amount INTEGER
) AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(FC_CLIENT_ID);

    RETURN QUERY
    SELECT
        u."id_cliente",
        u."limit",
        u."current_balance",
        t."submitted_at",
        t."kind",
        t."description",
        t."amount"
    FROM USUARIO u
    LEFT JOIN TRANSACAO t ON t.id_cliente = u.id_cliente
    WHERE u.id_cliente = FC_CLIENT_ID
    ORDER BY t.submitted_at DESC
    LIMIT 10;
END $$ LANGUAGE plpgsql;
