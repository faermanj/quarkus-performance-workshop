ALTER SYSTEM SET TIMEZONE TO 'UTC';

CREATE TYPE kind_movimentacao AS ENUM ('c', 'd');

CREATE UNLOGGED TABLE members (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  current_balance INTEGER NOT NULL DEFAULT 0,
  limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
  id  SERIAL PRIMARY KEY,
  id_cliente INTEGER NOT NULL REFERENCES members(id),
  kind kind_movimentacao NOT NULL,
  amount INTEGER NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ultima_transactions_por_cliente ON transactions (id_cliente, submitted_at DESC);

DO $$
BEGIN
  INSERT INTO members (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$