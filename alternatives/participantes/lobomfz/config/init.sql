CREATE TYPE "tipo_transacao" AS ENUM ('c', 'd');

CREATE TABLE
    "clientes" (
        "id" SERIAL NOT NULL,
        "saldo" INTEGER NOT NULL,
        "limite" INTEGER NOT NULL,
        CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
    );

CREATE TABLE
    "transactions" (
        "id" SERIAL NOT NULL,
        "valor" INTEGER NOT NULL,
        "id_cliente" INTEGER NOT NULL,
        "tipo" "tipo_transacao" NOT NULL,
        "descricao" VARCHAR(10) NOT NULL,
        "realizada_em" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
    );

ALTER TABLE "transactions" ADD CONSTRAINT "transactions_id_cliente_fkey" FOREIGN KEY ("id_cliente") REFERENCES "clientes" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

CREATE INDEX transactions_ordering ON transactions (realizada_em DESC, id_cliente);

INSERT INTO
    clientes (saldo, limite)
VALUES
    (0, 1000 * 100),
    (0, 800 * 100),
    (0, 10000 * 100),
    (0, 100000 * 100),
    (0, 5000 * 100);