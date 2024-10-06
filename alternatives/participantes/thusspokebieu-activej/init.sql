CREATE UNLOGGED TABLE IF NOT EXISTS members (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL 
);

CREATE INDEX IF NOT EXISTS idx_members ON members USING btree(id);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_transactions_cliente_id ON transactions USING btree(cliente_id);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM members) THEN
        INSERT INTO members (limit, current_balance)
        VALUES
            (1000 * 100, 0),
            (800 * 100, 0),
            (10000 * 100, 0),
            (100000 * 100, 0),
            (5000 * 100, 0);
    END IF;
END;
$$;



CREATE OR REPLACE FUNCTION balance(_cliente_id INTEGER)
RETURNS JSON AS $$
DECLARE
    current_balance JSON;
    recent_transactions JSON;
BEGIN
    SELECT
        json_build_object(
            'total', c.current_balance,
            'date_balance', NOW(),
            'limit', c.limit
        )
    INTO
        current_balance
    FROM
        members c
    WHERE
        c.id = _cliente_id;

    IF NOT FOUND THEN 
      RETURN NULL;
    END IF;

    SELECT
        CASE
            WHEN COUNT(*) > 0 THEN json_agg(json_build_object(
                'amount', t.amount,
                'kind', t.kind,
                'description', t.description,
                'submitted_at', t.submitted_at
            ))
            ELSE '[]'::JSON
        END
    INTO
        recent_transactions
    FROM (
        SELECT
            amount,
            kind,
            description,
            submitted_at
        FROM
            transactions
        WHERE
            cliente_id = _cliente_id
        ORDER BY
            id DESC
        LIMIT 10
    ) t;

    RETURN json_build_object(
        'current_balance', current_balance,
        'recent_transactions', recent_transactions
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION transacao(
    _cliente_id INTEGER,
    _amount INTEGER,
    _kind CHAR,
    _description VARCHAR(10),
    OUT status SMALLINT,
    OUT resultado JSON
)
RETURNS record AS
$$
BEGIN
        IF _kind = 'c' THEN
            UPDATE members 
            SET current_balance = current_balance + _amount 
            WHERE id = _cliente_id 
            RETURNING json_build_object('limit', limit, 'current_balance', current_balance) INTO resultado;
            INSERT INTO transactions(cliente_id, amount, kind, description)
            VALUES (_cliente_id, _amount, _kind, _description);
            status := 200;
        ELSIF _kind = 'd' THEN
            UPDATE members
            SET current_balance = current_balance - _amount
            WHERE id = _cliente_id AND current_balance - _amount > -limit
            RETURNING json_build_object('limit', limit, 'current_balance', current_balance) INTO resultado;
            
            IF FOUND THEN 
              INSERT INTO transactions(cliente_id, amount, kind, description)
              VALUES (_cliente_id, _amount, _kind, _description);
              status := 200;
            ELSE 
              status := 422;
              resultado := '';
            END IF;
        ELSE
            status := 422;
            resultado := '';
        END IF;
END;
$$
LANGUAGE plpgsql;

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
SELECT pg_prewarm('transactions');
SELECT pg_prewarm('idx_members');
SELECT pg_prewarm('idx_transactions_cliente_id');
