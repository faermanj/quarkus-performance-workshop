DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS transactions;

CREATE TABLE IF NOT EXISTS clientes (
                                        id INTEGER PRIMARY KEY,
                                        limit INTEGER NOT NULL,
                                        current_balance INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
                                          id SERIAL PRIMARY KEY,
                                          cliente_id INTEGER NOT NULL,
                                          kind CHAR(1) NOT NULL,
                                          amount INTEGER NOT NULL,
                                          description VARCHAR(10) NOT NULL,
                                          submitted_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX ON transactions (cliente_id, submitted_at DESC);

INSERT INTO clientes
(id, limit, current_balance)
VALUES
    (1, 100000,     0),
    (2, 80000,      0),
    (3, 1000000,    0),
    (4, 10000000,   0),
    (5, 500000,     0);

CREATE OR REPLACE FUNCTION update_current_balance_cliente(id INT, amount INT, kind VARCHAR, description VARCHAR)
RETURNS TABLE(new_current_balance INT, limit INT) AS $$
DECLARE
  current_balance INTEGER;
limit INTEGER;
new_current_balance INTEGER;
BEGIN
SELECT c.current_balance, c.limit INTO current_balance, limit
FROM clientes c
WHERE c.id = update_current_balance_cliente.id FOR UPDATE;

IF update_current_balance_cliente.kind = 'd' THEN
    new_current_balance := current_balance - update_current_balance_cliente.amount;
IF new_current_balance + limit < 0 THEN
      RAISE EXCEPTION 'Updating current_balance failed: new current_balance exceeds the limit' USING ERRCODE = 'P0000';
END IF;
ELSE
    new_current_balance := current_balance + update_current_balance_cliente.amount;
END IF;

UPDATE clientes c SET current_balance = new_current_balance WHERE c.id = update_current_balance_cliente.id;

INSERT INTO transactions (cliente_id, kind, amount, description, submitted_at)
VALUES (
           update_current_balance_cliente.id,
           update_current_balance_cliente.kind,
           update_current_balance_cliente.amount,
           update_current_balance_cliente.description,
           CURRENT_TIMESTAMP
       );

RETURN QUERY SELECT new_current_balance, limit;
END;
$$ LANGUAGE plpgsql;
