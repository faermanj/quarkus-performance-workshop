DROP TYPE IF EXISTS criartransacao_result;
CREATE TYPE criartransacao_result AS (
  result integer,
  current_balance integer,
  limit integer
);
CREATE OR REPLACE FUNCTION criartransacao(
  IN idcliente integer,
  IN amount integer,
  IN description varchar(10)
) RETURNS criartransacao_result AS $$
DECLARE
  clienteencontrado cliente%rowtype;
  search RECORD;
  ret criartransacao_result;
BEGIN
  SELECT * FROM cliente
  INTO clienteencontrado
  WHERE id = idcliente;

  IF not found THEN
    SELECT -1, 0, 0 into ret;
    RETURN ret;
  END IF;

  INSERT INTO transacao (amount, description, realizadaem, idcliente)
    VALUES (amount, description, now() at time zone 'utc', idcliente);
  UPDATE cliente
    SET current_balance = current_balance + amount
    WHERE id = idcliente AND (amount > 0 OR current_balance + amount >= limit)
    RETURNING current_balance, limit
    INTO search;
  IF search.limit is NULL THEN
    SELECT -2, 0, 0 INTO ret;
    RETURN ret;
  ELSE
    SELECT 0, search.current_balance, search.limit INTO ret;
  END IF;
  RETURN RET;
END;$$ LANGUAGE plpgsql;
