CREATE UNLOGGED TABLE cliente (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(10) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transacao (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
	FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE UNLOGGED TABLE current_balance (
  cliente_id INTEGER NOT NULL PRIMARY KEY,
  amount BIGINT NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

-- SALDO PROCEDURE CONTROL
CREATE OR REPLACE FUNCTION reconcile_current_balance()
  RETURNS TRIGGER
  LANGUAGE PLPGSQL
  AS
$$
DECLARE
	should_continue BOOLEAN;
BEGIN
  CASE WHEN NEW.kind = 'd' THEN
	 SELECT 
		CASE WHEN x.limit + (SELECT b.amount-NEW.amount FROM current_balance b WHERE b.cliente_id=x.id) < 0 THEN
			FALSE
		ELSE
			TRUE
		END INTO should_continue
	FROM cliente x WHERE x.id=NEW.cliente_id;

	CASE WHEN should_continue IS FALSE THEN
		RAISE EXCEPTION 'No limit';
	ELSE
		-- do nothing
	END CASE;
  ELSE
  	-- do nothing
  END CASE;

  INSERT INTO current_balance AS s (cliente_id, amount)
  VALUES (
  	NEW.cliente_id,
  	CASE WHEN NEW.kind = 'c' THEN NEW.amount ELSE NEW.amount * -1 END
  )
  ON CONFLICT (cliente_id) DO
  UPDATE SET amount = s.amount+EXCLUDED.amount;
  RETURN NEW;
END;
$$;

CREATE TRIGGER reconcile_current_balance
AFTER INSERT
ON transacao
FOR EACH ROW
EXECUTE PROCEDURE reconcile_current_balance();

-- POPULATE
DO $$
BEGIN
	INSERT INTO cliente (id, nome, limit)
	VALUES
		(1, 'cliente 1', 1000 * 100),
		(2, 'cliente 2', 800 * 100),
		(3, 'cliente 3', 10000 * 100),
		(4, 'cliente 4', 100000 * 100),
		(5, 'cliente 5', 5000 * 100);
END;
$$;

-- JAMAIS faça isso em produção. Vá para um elasticsearch.
CREATE INDEX idx_transacao_clientid_1 ON transacao (submitted_at DESC) WHERE cliente_id=1;
CREATE INDEX idx_transacao_clientid_2 ON transacao (submitted_at DESC) WHERE cliente_id=2;
CREATE INDEX idx_transacao_clientid_3 ON transacao (submitted_at DESC) WHERE cliente_id=3;
CREATE INDEX idx_transacao_clientid_4 ON transacao (submitted_at DESC) WHERE cliente_id=4;
CREATE INDEX idx_transacao_clientid_5 ON transacao (submitted_at DESC) WHERE cliente_id=5;
