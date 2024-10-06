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
    --raise notice'Id do Cliente % não encontrado.', idcliente;
    select -1 into ret;
    RETURN ret;
  END IF;

  --raise notice'Criando transacao para cliente %.', idcliente;
  INSERT INTO transacao (amount, description, realizadaem, idcliente)
    VALUES (amount, description, now() at time zone 'utc', idcliente);
  UPDATE cliente
    SET current_balance = current_balance + amount
    WHERE id = idcliente AND (amount > 0 OR current_balance + amount >= limit)
    RETURNING current_balance, limit
    INTO ret;
  raise notice'Ret: %', ret;
  IF ret.limit is NULL THEN
    --raise notice'Id do Cliente % não encontrado.', idcliente;
    select -2 into ret;
  END IF;
  RETURN ret;
END;$$ LANGUAGE plpgsql;