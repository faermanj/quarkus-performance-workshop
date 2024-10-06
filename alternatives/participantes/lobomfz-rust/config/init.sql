CREATE TYPE "kind_transacao" AS ENUM ('c', 'd');

CREATE TABLE
    "clientes" (
        "id" SERIAL NOT NULL,
        "current_balance" INTEGER NOT NULL,
        "limit" INTEGER NOT NULL,
        CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
    );

CREATE TABLE
    "transactions" (
        "id" SERIAL NOT NULL,
        "amount" INTEGER NOT NULL,
        "id_cliente" INTEGER NOT NULL,
        "kind" "kind_transacao" NOT NULL,
        "description" VARCHAR(10) NOT NULL,
        "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
    );

ALTER TABLE "transactions" ADD CONSTRAINT "transactions_id_cliente_fkey" FOREIGN KEY ("id_cliente") REFERENCES "clientes" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE INDEX transactions_ordering ON transactions (submitted_at DESC, id_cliente);

INSERT INTO
    clientes (current_balance, limit)
VALUES
    (0, 1000 * 100),
    (0, 800 * 100),
    (0, 10000 * 100),
    (0, 100000 * 100),
    (0, 5000 * 100);