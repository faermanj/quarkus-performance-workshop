CREATE OR REPLACE FUNCTION realizar_transacao(
    p_id int,
    p_amount int,
    p_kind char,
    p_description text,
    p_realizadaEm timestamp
) RETURNS RECORD AS $$
DECLARE 
  limit int;
  current_balance int;
  novo_current_balance int;
  novo_limit int;
  resultado RECORD;
BEGIN 
  -- Travar a tabela "Clientes" em modo exclusivo de linha
  LOCK TABLE "Clientes" IN ROW EXCLUSIVE MODE;
  
  -- Selecionar e travar a linha específica para atualização
  SELECT "Limite", "Saldo" INTO limit, current_balance 
  FROM "Clientes" c 
  WHERE "Id" = p_id 
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'cliente nao encontrado';
  END IF;

  -- Atualizar o current_balance com base no kind
  IF (p_kind = 'd') THEN
  	IF ((-p_amount + current_balance) < -limit) THEN 
    	RAISE EXCEPTION 'limit insuficiente';
 	END IF;
    UPDATE "Clientes" SET "Saldo" = current_balance - p_amount WHERE "Id" = p_id	
    RETURNING "Saldo" AS novo_current_balance, "Limite" AS novo_limit INTO novo_current_balance, novo_limit;
  ELSE
    UPDATE "Clientes" SET "Saldo" = current_balance + p_amount WHERE "Id" = p_id
    RETURNING "Saldo" AS novo_current_balance, "Limite" AS novo_limit INTO novo_current_balance, novo_limit;
  END IF;

  -- Inserir na tabela de transações
  INSERT INTO "transactions" ("Tipo", "Valor", "Descricao", "RealizadaEm", "ClienteId") 
  VALUES (p_kind, p_amount, p_description, p_realizadaEm, p_id);

  -- Retornar um record com os amountes atualizados
  resultado := (novo_current_balance, novo_limit);
  RETURN resultado;
END $$ LANGUAGE plpgsql;
