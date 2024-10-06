SET timezone TO 'UTC';

DROP TABLE IF EXISTS cliente;

DROP TABLE IF EXISTS transacao;

CREATE TABLE cliente(
    id serial PRIMARY KEY,
    limit integer NOT NULL,
    current_balance integer NOT NULL DEFAULT 0
);

CREATE TABLE transacao(
    id serial PRIMARY KEY,
    amount integer NOT NULL,
    description varchar(10) NOT NULL,
    kind char NOT NULL,
    submitted_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente integer NOT NULL
);

CREATE INDEX idx_cliente_id ON cliente(id);

CREATE INDEX idx_transacao_cliente_tempo ON transacao(id_cliente, submitted_at DESC);

CREATE INDEX idx_transacao_cliente_id ON transacao(id_cliente);

INSERT INTO cliente(id, limit, current_balance)
    VALUES (1, 1000 * 100, 0),
(2, 800 * 100, 0),
(3, 10000 * 100, 0),
(4, 100000 * 100, 0),
(5, 5000 * 100, 0);

CREATE OR REPLACE FUNCTION debit(_customer_id int, _transaction_value int, _transaction_description varchar(10))
RETURNS TABLE(success boolean, client_limit int, new_balance int)
LANGUAGE plpgsql
AS $$
DECLARE
    client_balance int;
    client_limit int;
BEGIN
    PERFORM pg_advisory_xact_lock(_customer_id);

    SELECT
        current_balance, limit
    INTO
        client_balance, client_limit
    FROM cliente
    WHERE id = _customer_id
    FOR UPDATE;
    --tried doing the other way around (new balance < -limit), but apparently a return doesn't end the function call, so even if the operation is not allowed, the balance gets updated
    IF (client_balance - _transaction_value) >= (-1 * client_limit) THEN
        UPDATE cliente
            SET current_balance = current_balance - _transaction_value
        WHERE id = _customer_id;

        INSERT INTO transacao(id_cliente, amount, kind, description)
            VALUES (_customer_id, _transaction_value, 'd', _transaction_description);

        RETURN QUERY SELECT TRUE, client_limit, client_balance - _transaction_value;
    ELSE
        RETURN QUERY SELECT FALSE, -1, -1;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Transaction rolled back: %', SQLERRM;
END;
$$;


CREATE OR REPLACE FUNCTION credit(_customer_id int, _transaction_value int, _transaction_description varchar(10))
RETURNS TABLE(success boolean, client_limit int, new_balance int)
LANGUAGE plpgsql
AS $$
DECLARE
    client_balance int;
    client_limit int;
BEGIN
    PERFORM pg_advisory_xact_lock(_customer_id);

    SELECT
        current_balance, limit
    INTO
        client_balance, client_limit
    FROM cliente
    WHERE id = _customer_id
    FOR UPDATE;

    UPDATE cliente
        SET current_balance = current_balance + _transaction_value
    WHERE id = _customer_id;

    INSERT INTO transacao(id_cliente, amount, kind, description)
        VALUES (_customer_id, _transaction_value, 'c', _transaction_description);

    RETURN QUERY SELECT TRUE, client_limit, client_balance + _transaction_value;

    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Transaction rolled back: %', SQLERRM;
END;
$$;


-- Still haven't tested using this one
CREATE OR REPLACE FUNCTION get_client_data(_customer_id int)
RETURNS TABLE(
    customer_balance int,
    customer_limit int,
    report_date timestamptz,
    last_transactions jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        current_balance, -- total
        limit,
        CURRENT_TIMESTAMP, -- date_balance
        COALESCE(
            json_agg(
                json_build_object('amount', trans.amount,'kind', trans.kind,'description', trans.description,'submitted_at', trans.submitted_at))
                FILTER (WHERE trans.amount IS NOT NULL
            ),
            '[]'
        )::jsonb -- recent_transactions
        FROM cliente
        LEFT OUTER JOIN (
            SELECT *
            FROM transacao
            WHERE id_cliente = _customer_id
            ORDER BY submitted_at DESC
            LIMIT 10
        ) trans
        ON cliente.id = trans.id_cliente
        WHERE cliente.id = _customer_id
        GROUP BY current_balance, limit;
END;
$$

-- UPDATE cliente SET current_balance = current_balance + 100 WHERE id = 1; INSERT INTO transacao(id_cliente, amount, kind, description) VALUES (1, 100, 'c', 'test');
-- UPDATE cliente SET current_balance = 0 WHERE id = 1; DELETE FROM transacao WHERE id_cliente = 1;

-- SELECT * FROM cliente WHERE id = @id LIMIT 1;
-- SELECT amount, kind, description, submitted_at FROM transacao WHERE id_cliente = @id ORDER BY submitted_at DESC LIMIT 10;
