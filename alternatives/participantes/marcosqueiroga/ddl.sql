CREATE UNLOGGED TABLE public.clientes (
	id SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(25) NOT NULL,
	limit INT NOT NULL,
	current_balance INT NOT NULL
);

CREATE UNLOGGED TABLE public.transactions (
	id SERIAL PRIMARY KEY NOT NULL,
	amount INT NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL,
	id_cliente INT NOT NULL
);

CREATE INDEX ix_transactions_id_cliente ON public.transactions
(
    id_cliente ASC
);

CREATE OR REPLACE FUNCTION public.insere_transacao(
  IN id_cliente INT,
  IN amount INT,
  IN description VARCHAR(10)
) RETURNS RECORD AS $$
DECLARE rec_cliente RECORD;
BEGIN
  SELECT limit, current_balance FROM public.clientes
    INTO rec_cliente
  WHERE id = id_cliente
  FOR UPDATE;

  IF rec_cliente.limit IS NULL THEN
    SELECT -1 INTO rec_cliente;
	RETURN rec_cliente;
  END IF;

  IF (amount < 0) AND (rec_cliente.current_balance + rec_cliente.limit + amount) < 0 THEN
    SELECT -2 INTO rec_cliente;
	RETURN rec_cliente;
  END IF;

  INSERT INTO public.transactions (amount, description, submitted_at, id_cliente)
                         VALUES (amount, description, now(), id_cliente);

  UPDATE public.clientes
    SET current_balance = current_balance + amount
    WHERE id = id_cliente
    RETURNING limit, current_balance
    INTO rec_cliente;

  RETURN rec_cliente;
END;$$ LANGUAGE plpgsql;


INSERT INTO public.clientes (nome, limit, current_balance)
  VALUES
    ('o barato sai caro', 1000 * 100, 0),
    ('zan corp ltda', 800 * 100, 0),
    ('les cruders', 10000 * 100, 0),
    ('padaria joia de cocaia', 100000 * 100, 0),
    ('kid mais', 5000 * 100, 0);