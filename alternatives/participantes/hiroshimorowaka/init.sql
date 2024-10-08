              DROP TABLE IF EXISTS "transactions";
              DROP TABLE IF EXISTS "clientes";
            
            
              CREATE UNLOGGED TABLE "clientes" (
                  id SERIAL NOT NULL,
                  nome TEXT NOT NULL,
                  limit INTEGER NOT NULL,
                  current_balance INTEGER NOT NULL DEFAULT 0,
              
                  CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
              );
              
              CREATE UNLOGGED TABLE "transactions" (
                  id SERIAL NOT NULL,
                  amount INTEGER NOT NULL,
                  kind CHAR(1) NOT NULL,
                  description VARCHAR(10) NOT NULL,
                  submitted_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
                  client_id INTEGER NOT NULL,
              
                  CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
              );
              
              CREATE INDEX idx_balance ON transactions (id DESC);
        
              CREATE UNIQUE INDEX "clientes_id_key" ON "clientes"("id");
              
              CREATE UNIQUE INDEX "transactions_id_key" ON "transactions"("id");
              
              ALTER TABLE "transactions" ADD CONSTRAINT "transactions_clientesId_fkey" FOREIGN KEY ("client_id") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
            
              DO $$
              BEGIN
                INSERT INTO clientes (nome, limit)
                VALUES
                  ('o barato sai caro', 1000 * 100),
                  ('zan corp ltda', 800 * 100),
                  ('les cruders', 10000 * 100),
                  ('padaria joia de cocaia', 100000 * 100),
                  ('kid mais', 5000 * 100);
              END; $$