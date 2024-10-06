-- create members table

CREATE UNLOGGED TABLE IF NOT EXISTS members (
   id SMALLINT PRIMARY KEY NOT NULL,
   limit INTEGER NOT NULL,
   current_balance INTEGER NOT NULL,
   recent_transactions JSONB not null default '[]'::jsonb,
   CONSTRAINT limit_minimo CHECK (current_balance > limit)
);

-- insert members

INSERT INTO members (id, limit, current_balance)
VALUES
    (1, -100000,0),
    (2, -80000,0),
    (3, -1000000,0),
    (4, -10000000,0),
    (5, -500000,0);

-- get_client function
CREATE OR REPLACE FUNCTION get_client(p_client_id SMALLINT)
RETURNS JSONB AS $$
DECLARE
   current_balance_result JSONB;
BEGIN
   SELECT jsonb_build_object(
      'current_balance', jsonb_build_object(
         'total', c.current_balance,
         'date_balance', current_timestamp,
         'limit', ABS(c.limit)
      ),
      'recent_transactions', c.recent_transactions
   )
   INTO current_balance_result
   FROM members c
   WHERE c.id = p_client_id;

   IF NOT FOUND THEN
      RAISE EXCEPTION 'cliente_not_found';
   END IF;

   RETURN current_balance_result;
END;
$$ LANGUAGE plpgsql;

-- add_transaction function
CREATE OR REPLACE FUNCTION add_transaction(client_id INTEGER, transaction JSONB)
RETURNS JSONB AS $$
DECLARE
   novocurrent_balance INTEGER;
   cliente RECORD;
BEGIN
   IF transaction ->> 'kind' = 'c' THEN
      novocurrent_balance := (transaction ->> 'amount')::INTEGER;
   ELSIF transaction ->> 'kind' = 'd' THEN
      novocurrent_balance := -(transaction ->> 'amount')::INTEGER;      

   END IF;

   UPDATE members
      SET
         current_balance = current_balance + novocurrent_balance,
         recent_transactions = jsonb_path_query_array(jsonb_insert(recent_transactions,'{0}', transaction), '$[0 to 9]')
      WHERE id = client_id
      RETURNING * INTO cliente;

   IF NOT FOUND THEN
      RAISE EXCEPTION 'cliente_not_found';
   END IF;

   RETURN jsonb_build_object('limit', ABS(cliente.limit), 'current_balance', cliente.current_balance);

END;
$$ LANGUAGE plpgsql;