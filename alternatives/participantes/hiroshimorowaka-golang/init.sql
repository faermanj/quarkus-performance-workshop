              DROP TABLE IF EXISTS "transactions";
              DROP TABLE IF EXISTS "members";
            
            
              CREATE UNLOGGED TABLE "members" (
                  id SERIAL NOT NULL,
                  nome TEXT NOT NULL,
                  limite INTEGER NOT NULL,
                  saldo INTEGER NOT NULL DEFAULT 0,
              
                  CONSTRAINT "members_pkey" PRIMARY KEY ("id")
              );
              
              CREATE UNLOGGED TABLE "transactions" (
                  id SERIAL NOT NULL,
                  valor INTEGER NOT NULL,
                  tipo CHAR(1) NOT NULL,
                  descricao VARCHAR(10) NOT NULL,
                  realizada_em TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
                  client_id INTEGER NOT NULL,
              
                  CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
              );
              
              CREATE INDEX idx_balance ON transactions (id DESC);
        
              CREATE UNIQUE INDEX "members_id_key" ON "members"("id");
              
              CREATE UNIQUE INDEX "transactions_id_key" ON "transactions"("id");
              
              ALTER TABLE "transactions" ADD CONSTRAINT "transactions_membersId_fkey" FOREIGN KEY ("client_id") REFERENCES "members"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
            
              DO $$
              BEGIN
                INSERT INTO members (nome, limite)
                VALUES
                  ('o barato sai caro', 1000 * 100),
                  ('zan corp ltda', 800 * 100),
                  ('les cruders', 10000 * 100),
                  ('padaria joia de cocaia', 100000 * 100),
                  ('kid mais', 5000 * 100);
              END; $$