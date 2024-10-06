CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX CONCURRENTLY idx_transactions_cliente_id
	ON transactions (cliente_id);

DO $$
BEGIN
	INSERT INTO members (nome, limit, current_balance)
	VALUES
		('o barato sai caro', 1000 * 100, 0),
		('zan corp ltda', 800 * 100, 0),
		('les cruders', 10000 * 100, 0),
		('padaria joia de cocaia', 100000 * 100, 0),
		('kid mais', 5000 * 100, 0);
	
END;
$$;

CREATE OR REPLACE FUNCTION debitar(
  cliente_id_tx INT,
  amount_tx INT,
  description_tx VARCHAR(10)
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
  record RECORD;
  _limit int;
  _current_balance int;
  success int;
BEGIN
  PERFORM pg_advisory_xact_lock(cliente_id_tx);

  UPDATE members
  SET current_balance = current_balance - amount_tx
  WHERE id = cliente_id_tx
  AND ABS(current_balance - amount_tx) <= limit
  RETURNING current_balance, limit INTO _current_balance, _limit;

  GET DIAGNOSTICS success = ROW_COUNT;

  IF success THEN
    INSERT INTO transactions (cliente_id, amount, kind, description)
      VALUES (cliente_id_tx, amount_tx, 'd', description_tx);

    RETURN (
      SELECT row_to_json(t) AS data
      FROM (
        SELECT _current_balance as current_balance, _limit as limit
      ) t
    );
  ELSE
    RETURN NULL;
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
  cliente_id_tx INT,
  amount_tx INT,
  description_tx VARCHAR(10)
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO transactions
    VALUES (DEFAULT, cliente_id_tx, amount_tx, 'c', description_tx, NOW());

  UPDATE members
  SET current_balance = current_balance + amount_tx
  WHERE id = cliente_id_tx;

  RETURN (
    SELECT row_to_json(t) AS data
    FROM (
      SELECT current_balance, limit
      FROM members
      WHERE id = cliente_id_tx
    ) t
  );
END;
$$;

CREATE OR REPLACE FUNCTION balance(
	clienteId INT
) 
RETURNS jsonb 
LANGUAGE plpgsql AS $$
DECLARE
  cd RECORD;
BEGIN
  
 RETURN (
  	SELECT 
   	 json_object(
     		'current_balance' VALUE json_object(
				'total' VALUE current_balance, 
				'limit' VALUE limit, 
				'date_balance' VALUE current_timestamp
			),
       		'recent_transactions' VALUE COALESCE(json_agg(t) FILTER (WHERE t.cliente_id IS NOT NULL), '[]')
     )
    FROM members c
    LEFT JOIN (
		SELECT t1.* 
		  FROM transactions t1 
		 WHERE t1.cliente_id = clienteId 
		 ORDER BY t1.id DESC 
		 LIMIT 10
	) t ON t.cliente_id = c.id
    WHERE c.id = clienteId
    GROUP BY c.id
 );
  
  
END;
$$;
