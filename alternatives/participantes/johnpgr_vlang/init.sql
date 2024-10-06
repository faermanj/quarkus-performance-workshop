CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0,
	recent_transactions JSONB NOT NULL DEFAULT '[]'::JSONB
);

DO $$
BEGIN
	INSERT INTO cliente (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
END;
$$;

CREATE OR REPLACE FUNCTION add_transacao(cliente_id INTEGER, transacao JSONB)
RETURNS JSONB AS $$
DECLARE
   amount_transacao INTEGER;
   cliente RECORD;
BEGIN
   IF transacao ->> 'kind' = 'c' THEN
      amount_transacao := (transacao ->> 'amount')::INTEGER;
   ELSIF transacao ->> 'kind' = 'd' THEN
      amount_transacao := -(transacao ->> 'amount')::INTEGER;
   END IF;

   UPDATE cliente
      SET
         current_balance = current_balance + amount_transacao,
         recent_transactions = jsonb_path_query_array(jsonb_insert(recent_transactions,'{0}', transacao), '$[0 to 9]')
      WHERE id = cliente_id
      AND amount_transacao + current_balance + limit >= 0
      RETURNING limit as limit, current_balance as current_balance INTO cliente;

   IF NOT FOUND THEN
      RETURN '{}'::JSONB;
   END IF;

   RETURN jsonb_build_object('limit', cliente.limit, 'current_balance', cliente.current_balance);
END;
$$ LANGUAGE plpgsql;
