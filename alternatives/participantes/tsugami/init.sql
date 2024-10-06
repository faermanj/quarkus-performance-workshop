-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM('c', 'd');

-- CreateTable
CREATE TABLE "accounts" (
    "id" SERIAL NOT NULL PRIMARY KEY,

    "current_balance" BIGINT NOT NULL,
    "limit" BIGINT NOT NULL
);

ALTER TABLE "accounts" ADD CONSTRAINT "accounts_current_balance_limit" CHECK ("current_balance" >= ~"limit");

-- CreateTable
CREATE TABLE "transactions" (
    "id" SERIAL NOT NULL PRIMARY KEY,
    "amount" BIGINT NOT NULL,
    "kind" "TransactionType" NOT NULL,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "account_id" INTEGER NOT NULL,
    "description" TEXT
);

-- AddForeignKey
ALTER TABLE "transactions"
ADD CONSTRAINT "transactions_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "accounts" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

DO $$
BEGIN
	INSERT INTO accounts (id, limit, current_balance)
	VALUES
		(1, 1000 * 100, 0),
		(2, 800 * 100, 0),
		(3, 10000 * 100, 0),
		(4, 100000 * 100, 0),
		(5, 5000 * 100, 0);
END;
$$;
