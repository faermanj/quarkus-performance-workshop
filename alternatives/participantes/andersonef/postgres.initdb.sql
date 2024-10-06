ALTER SYSTEM SET max_connections = 300;
/*ALTER SYSTEM SET shared_buffers = "75MB";
ALTER SYSTEM SET effective_cache_size = "225MB";
ALTER SYSTEM SET maintenance_work_mem = "19200kB";
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = "2304kB";
ALTER SYSTEM SET default_statistics_target = 100;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;
ALTER SYSTEM SET work_mem = "76kB";
ALTER SYSTEM SET huge_pages = off;
ALTER SYSTEM SET min_wal_size = "1GB";
ALTER SYSTEM SET max_wal_size = "4GB";*/

CREATE UNLOGGED TABLE IF NOT EXISTS clientes (id INTEGER PRIMARY KEY, limit INTEGER, current_balance INTEGER DEFAULT 0);
INSERT INTO clientes (id, limit) VALUES (1, 100000), (2, 80000), (3, 1000000), (4, 10000000), (5, 500000) ON CONFLICT DO NOTHING;
CREATE UNLOGGED TABLE IF NOT EXISTS transactions (id SERIAL PRIMARY KEY, id_cliente INTEGER, amount INTEGER, kind TEXT, description VARCHAR, submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(id_cliente) REFERENCES clientes(id));
DELETE FROM transactions;

CREATE OR REPLACE FUNCTION fn_add_transacao(p_id_cliente integer, p_amount INTEGER, p_kind text, p_description text) 
RETURNS TABLE (status text, current_balance INTEGER, limit integer) AS 
$$
DECLARE
   v_status text;
   v_current_balance INTEGER;
   v_limit integer;
   v_novo_current_balance INTEGER;
BEGIN
    SELECT c.current_balance, c.limit INTO v_current_balance, v_limit FROM clientes c WHERE c.id = p_id_cliente for update;
	v_novo_current_balance := v_current_balance + (CASE WHEN p_kind = 'c' THEN p_amount ELSE -p_amount end);
    IF v_novo_current_balance >= -v_limit THEN
        INSERT INTO transactions (id_cliente, amount, kind, description) VALUES (p_id_cliente, p_amount, p_kind, p_description);
        
        UPDATE clientes SET current_balance = v_novo_current_balance WHERE id = p_id_cliente;

        v_status := 'success';
        RETURN QUERY SELECT v_status, v_novo_current_balance, v_limit;
    ELSE
        v_status := 'error';
        RETURN QUERY SELECT v_status, v_current_balance, v_limit;
    END IF;

    --RETURN QUERY SELECT v_status, (case when v_status = 'success' then v_novo_current_balance else v_current_balance end), v_limit;
END;
$$
LANGUAGE plpgsql;
