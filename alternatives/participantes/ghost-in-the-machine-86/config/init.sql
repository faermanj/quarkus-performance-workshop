CREATE TABLE "clientes" (
    "id" SERIAL NOT NULL,
    "current_balance" INTEGER NOT NULL,
    "limit" INTEGER NOT NULL,

    CONSTRAINT "cli_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "transactions" (
    "id" SERIAL NOT NULL,
    "amount" INTEGER NOT NULL,
    "id_cliente" INTEGER NOT NULL,
    "kind" CHAR NOT NULL,
    "description" VARCHAR(10) NOT NULL,
    "submitted_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tra_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "tra_check1" CHECK (amount > 0),
    CONSTRAINT "tra_check2" CHECK (LENGTH(description) > 0),
    CONSTRAINT "tra_id_cliente_fkey" FOREIGN KEY ("id_cliente") REFERENCES "clientes" ("id")
);

CREATE INDEX tra_id_orderby ON transactions (submitted_at DESC, id_cliente);

CREATE OR REPLACE FUNCTION debit(p_id INTEGER, p_value INTEGER, p_description VARCHAR) RETURNS SETOF clientes AS $$
DECLARE
    v_client clientes%ROWTYPE;
    v_new_balance NUMERIC;
BEGIN
    PERFORM pg_advisory_xact_lock(p_id);
    SELECT * INTO v_client FROM clientes WHERE id = p_id LIMIT 1;
    IF (v_client IS NULL) THEN
        RAISE EXCEPTION 'P0002';
    END IF;

    v_new_balance := v_client.current_balance - p_value;
    IF (v_new_balance < (v_client.limit * -1)) THEN
        RAISE EXCEPTION '';
    END IF;

    INSERT INTO transactions (id_cliente, amount, kind, description) VALUES (p_id ,p_value, 'd', p_description );
    v_client.current_balance := v_new_balance;
    UPDATE clientes SET current_balance = v_new_balance WHERE id = p_id;
    RETURN NEXT v_client;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION credit(p_id INTEGER, p_value INTEGER, p_description VARCHAR) RETURNS SETOF clientes AS $$
DECLARE
    v_client clientes%ROWTYPE;
    v_new_balance NUMERIC;
BEGIN
    PERFORM pg_advisory_xact_lock(p_id);
    SELECT * INTO v_client FROM clientes WHERE id = p_id LIMIT 1;
    IF (v_client IS NULL) THEN
        RAISE EXCEPTION 'P0002';
    END IF;

    v_new_balance := v_client.current_balance + p_value;
    INSERT INTO transactions (id_cliente, amount, kind, description) VALUES (p_id, p_value, 'c', p_description);
    v_client.current_balance := v_new_balance;
    UPDATE clientes SET current_balance = v_new_balance WHERE id = p_id;
    RETURN NEXT v_client;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION statement(p_id INTEGER) RETURNS JSONB AS $$
DECLARE
    v_current_balance JSONB;
    v_transactions JSONB;
BEGIN
    PERFORM pg_advisory_xact_lock(p_id);
    SELECT jsonb_build_object('total', current_balance, 'date_balance', CURRENT_TIMESTAMP(6), 'limit', limit ) INTO v_current_balance FROM clientes WHERE id = p_id;
    IF (v_current_balance IS NULL) THEN
        RAISE EXCEPTION 'P0002';
    END IF;

    SELECT COALESCE(jsonb_agg(
               jsonb_build_object(
                   'amount', amount,
                   'kind', kind,
                   'description', description,
                   'submitted_at', submitted_at
               )
           ), '[]'::JSONB)
    INTO v_transactions FROM (
        SELECT amount, kind, description, submitted_at FROM transactions WHERE id_cliente = p_id ORDER BY submitted_at DESC LIMIT 10
    ) AS recent_transactions;
    RETURN jsonb_build_object('current_balance', v_current_balance, 'recent_transactions', v_transactions);
END;
$$ LANGUAGE PLPGSQL;


DO $$
BEGIN
	INSERT INTO clientes (current_balance, limit)
	VALUES
		(0, 100000),
		(0, 80000),
		(0, 1000000),
		(0, 10000000),
		(0, 500000);
END;
$$;