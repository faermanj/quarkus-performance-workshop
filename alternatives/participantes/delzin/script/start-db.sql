CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  limit INT,
  saldo INT,
  transactions JSONB
);

DO $$
BEGIN
  INSERT INTO clientes (limit, saldo, transactions)
  VALUES
    (1000 * 100, 0, '[]'),
    (800 * 100, 0, '[]'),
    (10000 * 100, 0, '[]'),
    (100000 * 100, 0, '[]'),
    (5000 * 100, 0, '[]');
END; $$;
