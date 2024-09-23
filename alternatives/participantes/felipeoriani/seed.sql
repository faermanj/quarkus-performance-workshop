DO $$
BEGIN
  TRUNCATE TABLE transactions;
  TRUNCATE TABLE clientes;
  INSERT INTO clientes (id) VALUES (1), (2), (3), (4), (5);
END;
$$;
