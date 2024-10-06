CREATE UNLOGGED TABLE clientes (
   id SERIAL PRIMARY KEY,
   nome VARCHAR(50) NOT NULL,
   limit INTEGER NOT NULL,
   current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
    id         SERIAL PRIMARY KEY,
    cliente_id INTEGER     NOT NULL,
    amount      INTEGER     NOT NULL,
    kind   CHAR(1)     NOT NULL,
    description  VARCHAR(10) NOT NULL,
    realizado_em  TIMESTAMP   NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
    CONSTRAINT fk_transactions_cliente_id
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO clientes (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);



CREATE OR REPLACE FUNCTION create_transacao_cliente(
  IN idcliente integer,
  IN amount integer,
  IN kind char(1),
  IN description varchar(10)
) RETURNS TABLE (found integer, sal integer, lim integer) AS $$
DECLARE
  clienteencontrado clientes%rowtype;
  current_balance_cliente INT;
  limit_cliente INT;
BEGIN
  SELECT * FROM clientes
  INTO clienteencontrado
  WHERE id = idcliente;

  IF not found THEN
    RETURN QUERY SELECT 0, 0, 0;
  END IF;

  INSERT INTO transactions (amount, description, kind, realizado_em, cliente_id)
    VALUES (amount, description, kind, now() at time zone 'utc', idcliente);

  UPDATE clientes 
    SET current_balance = current_balance + amount
    WHERE id = idcliente AND (amount > 0 OR current_balance + amount >= limit)
    RETURNING current_balance, limit
    INTO current_balance_cliente, limit_cliente;

    IF limit_cliente is NULL THEN
        RETURN QUERY SELECT 1, 0, 0;
    END IF;

    RETURN QUERY SELECT 2, current_balance_cliente, limit_cliente;
END;$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_transactions(
  IN idcliente integer
) RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_agg(json_build_object(
                  'amount', t.amount,
                  'kind', t.kind,
                  'description', t.description,
                  'realizado_em', t.realizado_em
                )) INTO result
    FROM (
        SELECT amount, kind, description, realizado_em
        FROM transactions
        WHERE cliente_id = idcliente
        ORDER BY realizado_em DESC
        LIMIT 10
    ) AS t;          
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION balance(
  IN idcliente integer
) RETURNS TABLE (total INT, date_balance TIMESTAMP, limite INT, recent_transactions JSON)  AS $$
DECLARE
  current_balance_cliente INT;
  limit_cliente INT;
BEGIN
    SELECT current_balance, limit FROM clientes
    INTO current_balance_cliente, limit_cliente
    WHERE id = idcliente;

    RETURN QUERY SELECT current_balance_cliente, NOW() at time zone 'utc' as data, limit_cliente, get_transactions(idcliente);
END;$$ LANGUAGE plpgsql;
