DO $$ BEGIN
 CREATE TYPE "transaction_type" AS ENUM('c', 'd');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "clientes" (
	"id" serial PRIMARY KEY NOT NULL,
	"limit" integer NOT NULL,
	"nome" varchar(50) NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "current_balances" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer,
	"amount" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "transactions" (
	"id" serial PRIMARY KEY NOT NULL,
	"client_id" integer,
	"amount" integer NOT NULL,
	"kind" "transaction_type",
	"description" varchar(50) NOT NULL,
	"submitted_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "client_id_idx" ON "current_balances" ("client_id");--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "current_balances" ADD CONSTRAINT "current_balances_client_id_clientes_id_fk" FOREIGN KEY ("client_id") REFERENCES "clientes"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "transactions" ADD CONSTRAINT "transactions_client_id_clientes_id_fk" FOREIGN KEY ("client_id") REFERENCES "clientes"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;



-- KEEP FOR SEED
DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO current_balances (client_id, amount)
		SELECT id, 0 FROM clientes;
END;
$$;