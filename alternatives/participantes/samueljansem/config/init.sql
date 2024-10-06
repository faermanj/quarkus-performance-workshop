SET CLIENT_MIN_MESSAGES = WARNING;
SET ROW_SECURITY = OFF;

CREATE UNLOGGED TABLE
    "members" (
        "id" INT PRIMARY KEY,
        "current_balance" INTEGER NOT NULL,
        "limit" INTEGER NOT NULL
    );

CREATE INDEX idx_pk_members ON members (id) INCLUDE (current_balance);
CLUSTER members USING idx_pk_members;

CREATE UNLOGGED TABLE
    "transactions" (
        "id" SERIAL PRIMARY KEY,
        "amount" INTEGER NOT NULL,
        "id_cliente" INTEGER NOT NULL,
        "kind" VARCHAR(1) NOT NULL,
        "description" VARCHAR(10) NOT NULL,
        "submitted_at" TIMESTAMP WITH TIME ZONE NOT NULL,
        CONSTRAINT "fk_transactions_id_cliente" FOREIGN KEY ("id_cliente") REFERENCES "members" ("id")
    );

CREATE INDEX idx_transactions_id_cliente ON transactions (id_cliente);
CREATE INDEX idx_transactions_submitted_at ON transactions (submitted_at DESC);
CLUSTER transactions USING idx_transactions_id_cliente;


ALTER TABLE "members" SET (autovacuum_enabled = false);
ALTER TABLE "transactions" SET (autovacuum_enabled = false);

INSERT INTO
    members (id, current_balance, limit)
VALUES
    (1, 0, 100000),
    (2, 0, 80000),
    (3, 0, 1000000),
    (4, 0, 10000000),
    (5, 0, 500000);

CREATE OR REPLACE PROCEDURE criar_transacao_e_atualizar_current_balance(
    id_cliente INTEGER,
    amount INTEGER,
    kind VARCHAR(1),
    description VARCHAR(10),
    submitted_at TIMESTAMP WITH TIME ZONE,
    INOUT current_balance_atual INTEGER DEFAULT NULL,
    INOUT limit_atual INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    amount_absoluto INTEGER;
BEGIN
    amount_absoluto := amount;

    IF kind = 'd' THEN
        amount := -amount;
    END IF;

    UPDATE members
    SET current_balance = current_balance + amount
    WHERE id = id_cliente AND (current_balance + amount) >= -limit
    RETURNING current_balance, limit INTO current_balance_atual, limit_atual;

    INSERT INTO transactions (amount, id_cliente, kind, description, submitted_at)
    VALUES (amount_absoluto, id_cliente, kind, description, submitted_at);
END;
$$;
