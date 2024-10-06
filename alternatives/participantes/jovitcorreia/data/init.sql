DROP TABLE IF EXISTS transacao;
DROP TABLE IF EXISTS cliente;

CREATE UNLOGGED TABLE cliente (
    id     SMALLSERIAL PRIMARY KEY,
    limit INT NOT NULL,
    current_balance  BIGINT NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transacao (
   id           SERIAL PRIMARY KEY,
   cliente_id   SMALLINT NOT NULL,
   amount        BIGINT NOT NULL,
   kind         CHAR(1) NOT NULL,
   description    TEXT NOT NULL,
   submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()::timestamp,
   CONSTRAINT fk_transacao_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id)
);

CREATE INDEX ON transacao (cliente_id, submitted_at DESC);

CREATE OR REPLACE FUNCTION public.get_stmt(c INT)
    RETURNS JSON AS
$$
DECLARE
    holder JSON;
    tnxs   JSON;
BEGIN
    SELECT json_build_object(
        'total', current_balance,
        'date_balance', to_char(now() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'),
        'limit', limit
    )
    INTO holder
    FROM cliente
    WHERE id = c;

    SELECT json_agg(
       json_build_object(
           'amount', amount,
           'kind', kind,
           'description', description,
           'submitted_at', to_char(submitted_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"')
       )
    ) INTO tnxs
    FROM (
        SELECT amount, kind, description, submitted_at
        FROM transacao
        WHERE cliente_id = c
        ORDER BY submitted_at DESC
        LIMIT 10
    ) AS t;

    RETURN json_build_object('current_balance', holder, 'recent_transactions', COALESCE(tnxs, '[]'::json));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.set_txn(
    c INT,
    d TEXT,
    t TEXT,
    v BIGINT
) RETURNS JSON AS
$$
DECLARE
    s BIGINT;
    n BIGINT;
    l INT;
BEGIN
    SELECT current_balance INTO s FROM cliente WHERE id = c FOR UPDATE;
    SELECT limit INTO l FROM cliente WHERE id = c;

    IF t = 'c' THEN
        n := s + v;
    ELSE
        n := s - v;
    END IF;

    IF n >= -l THEN
        UPDATE cliente SET current_balance = n WHERE id = c;
        INSERT INTO transacao(cliente_id, amount, kind, description) VALUES (c, v, t, d);
        RETURN json_build_object('limit', l, 'current_balance', n);
    END IF;
END;
$$ LANGUAGE plpgsql;

DO
$$
    BEGIN
        INSERT INTO cliente (limit)
        VALUES (100000), (80000), (1000000), (10000000), (500000);
    END;
$$;
