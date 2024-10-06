-- CreateEnum
CREATE TYPE "TipoTransacao" AS ENUM ('c', 'd');

-- CreateTable
CREATE TABLE "members" (
    "id_cliente" SERIAL NOT NULL,
    "nome" VARCHAR(256) NOT NULL,
    "limit" INTEGER NOT NULL,

    CONSTRAINT "members_pkey" PRIMARY KEY ("id_cliente")
);

-- CreateTable
CREATE TABLE "transactions" (
    "id" SERIAL NOT NULL,
    "id_cliente" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,
    "kind" "TipoTransacao" NOT NULL,
    "description" VARCHAR(10) NOT NULL,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "current_balances" (
    "id_cliente" INTEGER NOT NULL,
    "amount" INTEGER NOT NULL,

    CONSTRAINT "current_balances_pkey" PRIMARY KEY ("id_cliente")
);

-- CreateIndex
CREATE UNIQUE INDEX "current_balances_id_cliente_key" ON "current_balances"("id_cliente");

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_id_cliente_fkey" FOREIGN KEY ("id_cliente") REFERENCES "members"("id_cliente") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "current_balances" ADD CONSTRAINT "current_balances_id_cliente_fkey" FOREIGN KEY ("id_cliente") REFERENCES "members"("id_cliente") ON DELETE RESTRICT ON UPDATE CASCADE;

DO $$
BEGIN
	INSERT INTO members (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO current_balances (id_cliente, amount)
		SELECT id_cliente, 0 FROM members;
END;
$$;