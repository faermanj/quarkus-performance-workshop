CREATE TABLE IF NOT EXISTS clientes (
  id     SERIAL PRIMARY KEY,
  nome   TEXT NOT NULL,
  limit INTEGER NOT NULL,
  current_balance  INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
  id           SERIAL PRIMARY KEY,
  amount        INTEGER NOT NULL,
  kind         CHAR(1) NOT NULL,
  description    VARCHAR(10) NOT NULL,
  cliente_id   INTEGER NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

ALTER TABLE
  transactions
  SET
    (autovacuum_enabled = false);

CREATE INDEX IF NOT EXISTS idx_transactions ON transactions (cliente_id);

INSERT INTO clientes (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);
