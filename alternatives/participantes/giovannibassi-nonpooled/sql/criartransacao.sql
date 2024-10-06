CREATE OR REPLACE FUNCTION criartransacao(
  IN idcliente integer,
  IN amount integer,
  IN description varchar(10)
) RETURNS RECORD AS $$
DECLARE
  clienteencontrado cliente%rowtype;
  ret RECORD;
BEGIN
  SELECT * FROM cliente
  INTO clienteencontrado
  WHERE id = idcliente;

  IF not found THEN
    SELECT -1 INTO ret;
    RETURN ret;
  END IF;

  UPDATE cliente
    SET current_balance = current_balance + amount
    WHERE id = idcliente AND (amount > 0 OR current_balance + amount >= limit)
    RETURNING current_balance, limit
    INTO ret;
  IF ret.limit is NULL THEN
    SELECT -2 INTO ret;
    RETURN ret;
  END IF;
  INSERT INTO transacao (amount, description, idcliente)
    VALUES (amount, description, idcliente);
  RETURN ret;
END;$$ LANGUAGE plpgsql;
