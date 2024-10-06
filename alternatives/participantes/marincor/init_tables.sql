DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS transactions;
DROP TYPE IF EXISTS "kind_transacao";

CREATE TYPE "kind_transacao" AS ENUM ('c', 'd');

CREATE TABLE IF NOT EXISTS clientes (
    "id" SERIAL NOT NULL,
    "current_balance" INTEGER NOT NULL CHECK (current_balance >= -"limit"),
    "limit" INTEGER NOT NULL,
    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

CREATE INDEX idx_cliente_client_id
ON clientes ("id");

CREATE TABLE IF NOT EXISTS transactions (
    "id" SERIAL NOT NULL,
    "amount" INTEGER NOT NULL,
    "id_cliente" INTEGER NOT NULL,
    "kind" "kind_transacao" NOT NULL,
    "description" VARCHAR(10) NOT NULL,
    "submitted_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT transactions_pkey PRIMARY KEY ("id"),
    CONSTRAINT fk_clientes_transactions_id FOREIGN KEY ("id_cliente") REFERENCES clientes("id")
);

CREATE INDEX idx_transactions_client_id
ON transactions ("id_cliente");

INSERT INTO
    clientes (current_balance, limit)
VALUES
    (0, 1000 * 100),
    (0, 800 * 100),
    (0, 10000 * 100),
    (0, 100000 * 100),
    (0, 5000 * 100);