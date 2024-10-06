CREATE TABLE clientes (
  id SERIAL PRIMARY KEY NOT NULL,
  nome VARCHAR(23) NOT NULL, 
  limit INTEGER NOT NULL CHECK (limit >= 0),
  current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY NOT NULL,
  id_cliente INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10),
  submitted_at TIMESTAMPTZ NOT NULL,

  CONSTRAINT clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE PROCEDURE fazer_transacao (
  t_id_cliente INTEGER,
  t_amount INTEGER,
  t_kind CHAR(1),
  t_description VARCHAR(10),
  INOUT c_current_balance_atualizado INTEGER DEFAULT NULL,
  INOUT c_limit_out INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE 
  c_current_balance INTEGER;
  c_limit INTEGER;
BEGIN
  BEGIN
    SELECT current_balance, limit INTO c_current_balance, c_limit FROM clientes WHERE id = t_id_cliente FOR UPDATE;
    IF t_kind = 'c' THEN
      UPDATE clientes SET current_balance = c_current_balance + t_amount WHERE id = t_id_cliente;
      INSERT INTO transactions (id_cliente, amount, kind, description, submitted_at) VALUES (t_id_cliente, t_amount, t_kind, t_description, CURRENT_TIMESTAMP);
    ELSE
      IF c_current_balance - t_amount >= c_limit * -1 THEN
        UPDATE clientes SET current_balance = c_current_balance - t_amount WHERE id = t_id_cliente;
        INSERT INTO transactions (id_cliente, amount, kind, description, submitted_at) VALUES (t_id_cliente, t_amount, t_kind, t_description, CURRENT_TIMESTAMP);
      ELSE
        RAISE EXCEPTION 'transação ultrapassa o limit disponível';
      END IF;
    END IF;
    SELECT current_balance, limit INTO c_current_balance_atualizado, c_limit_out FROM clientes WHERE id = t_id_cliente;
    COMMIT;
  END;
END;
$$;


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
