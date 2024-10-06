-- CreateTable
-- CreateTable
CREATE TABLE "clientes" (
    "id" SERIAL NOT NULL,
    "limit" INTEGER NOT NULL,
    "current_balance" INTEGER NOT NULL,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transactions" (
    "id" SERIAL NOT NULL,
    "cliente_id" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "kind" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "submitted_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "transactions_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "clientes" ("id")
);

INSERT INTO
  "clientes" ("limit","current_balance")
VALUES
  (100000, 0),
  (80000, 0),
  (1000000, 0),
  (10000000, 0),
  (500000, 0);

-- CREATE TABLE "clientes" (
--     "id" SERIAL NOT NULL,
--     "limit" INTEGER NOT NULL,
--     "current_balance" INTEGER NOT NULL,

--     CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
-- );

-- -- CreateTable
-- CREATE TABLE "transactions" (
--     "id" SERIAL NOT NULL,
--     "cliente_id" INTEGER NOT NULL,
--     "amount" INTEGER NOT NULL,
--     "kind" TEXT NOT NULL,
--     "description" TEXT NOT NULL,
--     "submitted_at" TIMESTAMP(3) NOT NULL,

--     CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
-- );
