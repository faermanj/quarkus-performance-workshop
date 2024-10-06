-- DROP TABLE IF EXISTS
DROP TABLE IF EXISTS "transactions";

DROP TABLE IF EXISTS "members";

-- CreateTable
CREATE TABLE "members" (
  "id" SERIAL NOT NULL,
  "nome" VARCHAR(255) NOT NULL,
  "limit" INTEGER NOT NULL,
  "current_balance" INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT "members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transactions" (
  "id" SERIAL NOT NULL,
  "amount" INTEGER NOT NULL,
  "kind" CHAR(1) NOT NULL,
  "description" TEXT,
  "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "cliente_id" INTEGER,
  CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE
  "transactions"
ADD
  CONSTRAINT "transactions_cliente_id_fkey" FOREIGN KEY ("cliente_id") REFERENCES "members"("id") ON DELETE
SET
  NULL ON UPDATE CASCADE;

INSERT INTO
  members (id, nome, limit, current_balance)
VALUES
  (1, 'o barato sai caro', 100000, 0),
  (2, 'zan corp ltda', 80000, 0),
  (3, 'les cruders', 1000000, 0),
  (4, 'padaria joia de cocaia', 10000000, 0),
  (5, 'kid mais', 500000, 0);