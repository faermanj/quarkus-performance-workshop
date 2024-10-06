CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL CHECK(current_balance >= -limit)
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
    INSERT INTO clientes (limit, current_balance)
    VALUES
        (1000   * 100, 0),
        (800    * 100, 0),
        (10000  * 100, 0),
        (100000 * 100, 0),
        (5000   * 100, 0);
END;
$$;


CREATE OR REPLACE FUNCTION push_credito(
    cliente_id_in INTEGER,
    amount_in INTEGER,
    description_in VARCHAR(10)
)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE 
  ret json;
BEGIN
    WITH rw AS (
        UPDATE clientes SET current_balance = current_balance + amount_in
        WHERE id = cliente_id_in
        RETURNING limit, current_balance
    ) SELECT to_json(rw) FROM rw INTO ret;

    IF NOT FOUND THEN RETURN NULL;
    END IF;

    INSERT INTO transactions(cliente_id, amount, kind, description)
    VALUES (cliente_id_in, amount_in, 'c' ,description_in);

    RETURN ret;
END
$$;

CREATE OR REPLACE FUNCTION push_debito(
    cliente_id_in int,
    amount_in int,
    description_in varchar(10)
)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE 
  ret json;
BEGIN
    WITH rw AS (
        UPDATE clientes SET current_balance = current_balance - amount_in
        WHERE id = cliente_id_in
        RETURNING limit, current_balance
    ) SELECT to_json(rw) FROM rw INTO ret;

    IF NOT FOUND THEN RETURN NULL;
    END IF;

    INSERT INTO transactions(cliente_id, amount, kind, description)
    VALUES (cliente_id_in, amount_in, 'd' ,description_in);
    
    RETURN ret;

EXCEPTION
    WHEN check_violation THEN RETURN NULL;
END
$$;


CREATE OR REPLACE FUNCTION get_balance(
    cliente_id_in int
)
RETURNS json
LANGUAGE plpgsql
AS $$
DECLARE 
  ret json;
BEGIN
    SELECT json_build_object (
        'current_balance', (
            SELECT to_json(sld) FROM (
                SELECT current_balance AS total, LOCALTIMESTAMP AS date_balance, limit
                FROM clientes WHERE clientes.id = cliente_id_in LIMIT 1
            ) sld
        ),
        'recent_transactions',(
            SELECT coalesce(json_agg(tr), '[]'::json) FROM (
                SELECT amount, kind, description, submitted_at FROM transactions
                WHERE cliente_id = cliente_id_in ORDER BY submitted_at DESC LIMIT 10
            ) tr
        )
    ) INTO ret;
    IF NOT FOUND THEN
        ret := NULL;
    END IF;
    RETURN ret;
END
$$;

-- CONFIGURATIONS
ALTER SYSTEM SET max_connections = '201';
ALTER SYSTEM SET shared_buffers = '115MB';
ALTER SYSTEM SET effective_cache_size = '345MB';
ALTER SYSTEM SET maintenance_work_mem = '29440kB';
ALTER SYSTEM SET checkpoint_completion_target = '0.9';
ALTER SYSTEM SET wal_buffers = '3532kB';
ALTER SYSTEM SET default_statistics_target = '100';
ALTER SYSTEM SET random_page_cost = '4';
ALTER SYSTEM SET effective_io_concurrency = '2';
ALTER SYSTEM SET work_mem = '292kB';
ALTER SYSTEM SET huge_pages = 'off';
ALTER SYSTEM SET min_wal_size = '20GB';
ALTER SYSTEM SET max_wal_size = '80GB';
ALTER SYSTEM SET fsync = 'off';
ALTER SYSTEM SET synchronous_commit = 'off';
ALTER SYSTEM SET full_page_writes = 'off';
ALTER SYSTEM SET checkpoint_timeout = '600';