CREATE TABLE clientes (
    id      SERIAL PRIMARY KEY,
    nome    VARCHAR(50) NOT NULL,
    limit   INT NOT NULL,
    current_balance   INT DEFAULT 0 NOT NULL 
);


CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    amount INT NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_clientes_transactions_id FOREIGN KEY(cliente_id) REFERENCES clientes(id)
);


CREATE OR REPLACE FUNCTION create_transaction_func(
  p_cliente_id INTEGER,
  p_amount INTEGER,
  p_kind CHAR(1),
  p_description VARCHAR(10), OUT v_current_balance INT, OUT v_limit INT
)
LANGUAGE plpgsql
AS $$
BEGIN
  SELECT limit, current_balance INTO v_limit, v_current_balance FROM clientes WHERE id = p_cliente_id FOR UPDATE;

  IF p_kind = 'c' THEN
    v_current_balance = v_current_balance + p_amount;
    UPDATE clientes SET current_balance = current_balance + p_amount WHERE id = p_cliente_id;
  ELSIF p_kind = 'd' THEN
    IF (v_current_balance + v_limit - p_amount) < 0 THEN
      RAISE EXCEPTION 'Limite insuficiente!';
    ELSE
	  v_current_balance = v_current_balance - p_amount;
      UPDATE clientes SET current_balance = current_balance - p_amount WHERE id = p_cliente_id;
    END IF;
  ELSE
    RAISE EXCEPTION 'Transacao Invalida!';
  END IF;

  INSERT INTO transactions (cliente_id, amount, kind, description)
  VALUES (p_cliente_id, p_amount, p_kind, p_description);
END;
$$;

DO $$
BEGIN

    INSERT INTO clientes (nome, limit)
      VALUES
        ('Joao', 1000 * 100),
        ('Jose', 800 * 100),
        ('Maria', 10000 * 100),
        ('Pedro', 100000 * 100),
        ('Isabel', 5000 * 100);
END; $$