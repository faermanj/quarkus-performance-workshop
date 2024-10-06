CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  limit INT,
  current_balance INT
);

CREATE TABLE transactions (
  client_id INT,
  amount INT,
  kind VARCHAR(1),
  description VARCHAR(10),
  data_transacao TIMESTAMPTZ,
  CONSTRAINT fk_client
      FOREIGN KEY(client_id) 
        REFERENCES clientes(id)
);

DO $$
BEGIN
  INSERT INTO clientes (limit, current_balance)
  VALUES
    (1000 * 100, 0),
    (800 * 100, 0),
    (10000 * 100, 0),
    (100000 * 100, 0),
    (5000 * 100, 0);
END; $$;

CREATE TYPE save_transaction_result AS (limit int, current_balance int);

CREATE OR REPLACE FUNCTION save_transaction(IN client_id INT, IN amount INT, IN kind CHAR(1), IN description VARCHAR(10)) RETURNS save_transaction_result
LANGUAGE plpgsql
AS $$
DECLARE
    l INT;
    s INT;
BEGIN
    SELECT limit, current_balance INTO l, s FROM clientes WHERE id = client_id FOR UPDATE;

    IF kind = 'd' AND (s - amount) >= l * -1 THEN
        UPDATE clientes SET current_balance = s - amount WHERE id = client_id;
        s := s - amount;
    ELSIF kind = 'c' THEN
        UPDATE clientes SET current_balance = s + amount WHERE id = client_id;
        s := s + amount;
    ELSIF kind = 'd' AND (s - amount) < l * -1 THEN
      RETURN NULL;
    END IF;

    INSERT INTO transactions (client_id, amount, kind, description, data_transacao) VALUES (client_id, amount, kind, description, NOW());

    RETURN (l, s);
END $$;

CREATE INDEX idx_client ON transactions (client_id ASC)