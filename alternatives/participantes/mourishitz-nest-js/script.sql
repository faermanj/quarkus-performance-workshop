CREATE TABLE IF NOT EXISTS members (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(10),
  current_balance INT DEFAULT 0,
  limit INT
);

CREATE TABLE IF NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  cliente_id INT,
  amount INT,
  kind VARCHAR(1),
  description VARCHAR(10),
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_cliente
    FOREIGN KEY(cliente_id) REFERENCES members(id)
);

ALTER TABLE members
ADD CONSTRAINT checar_current_balance
CHECK (current_balance >= -limit);

CREATE OR REPLACE FUNCTION checar_limit_current_balance()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS(
    SELECT 1 FROM members WHERE id = NEW.cliente_id AND (current_balance - NEW.amount) < -limit
  ) THEN
    RAISE EXCEPTION 'Transação Inválida: Saldo negativo não pode ser menor do que seu limit.';
  END IF;
  RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER before_transaction_insert
BEFORE INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION checar_limit_current_balance();

DO $$

BEGIN
  INSERT INTO members (nome, limit)
  VALUES
    ('Cliente 1', 100000),
    ('Cliente 2', 80000),
    ('Cliente 3', 1000000),
    ('Cliente 4', 10000000),
    ('Cliente 5', 500000);
END; $$
