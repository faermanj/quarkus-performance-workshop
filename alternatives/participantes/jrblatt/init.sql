CREATE UNLOGGED TABLE "clientes" (
    "id" SERIAL NOT NULL,
    "current_balance" INTEGER NOT NULL,
    "limit" INTEGER NOT NULL,

    CONSTRAINT "clientes_pkey" PRIMARY KEY ("id")
);

CREATE UNLOGGED TABLE "transactions" (
    "id" SERIAL NOT NULL,
    "amount" INTEGER NOT NULL,
    "id_cliente" INTEGER NOT NULL,
    "kind" CHAR(1) NOT NULL,
    "description" VARCHAR(10) NOT NULL,
    "submitted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "transactions_id_cliente_fkey" FOREIGN KEY ("id_cliente") REFERENCES "clientes"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE INDEX idx_current_balance_limit ON clientes (current_balance, limit);
CREATE INDEX idx_id_cliente ON transactions (id_cliente);

CREATE OR REPLACE FUNCTION debitar(
  IN id_cliente integer,
  IN amount integer,
  IN description varchar(10)
) RETURNS json AS $$

DECLARE
  ret RECORD;
BEGIN
  INSERT INTO transactions (amount, description, submitted_at, id_cliente, kind)
    VALUES (amount, description, now() at time zone 'utc', id_cliente, 'd');
  UPDATE clientes
    SET current_balance = current_balance - amount
    WHERE id = id_cliente AND (current_balance - amount >= limit * -1)
    RETURNING current_balance, limit
    INTO ret;
  IF ret.limit is NULL THEN
    ret.current_balance := -6; -- se
    ret.limit := -9; -- xo
  END IF;
  RETURN row_to_json(ret);
END;$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION creditar(
  IN id_cliente integer,
  IN amount integer,
  IN description varchar(10)
) RETURNS json AS $$
DECLARE
  ret RECORD;
BEGIN
  INSERT INTO transactions (amount, description, submitted_at, id_cliente, kind)
    VALUES (amount, description, now() at time zone 'utc', id_cliente, 'c');
  UPDATE clientes
    SET current_balance = current_balance + amount
    WHERE id = id_cliente
    RETURNING current_balance, limit
    INTO ret;
    
  RETURN row_to_json(ret);
END;$$ LANGUAGE plpgsql;

DO $$
BEGIN
    INSERT INTO clientes (current_balance, limit)
    VALUES
        (0, 1000 * 100),
        (0, 800 * 100),
        (0, 10000 * 100),
        (0, 100000 * 100),
        (0, 5000 * 100);
END;
$$;