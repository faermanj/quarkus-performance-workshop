SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(255) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);


CREATE INDEX IF NOT EXISTS idx_cliente_id ON members(id);
CREATE INDEX IF NOT EXISTS idx_transacao_id_cliente_submitted_at_desc ON transactions(cliente_id, submitted_at DESC);

INSERT INTO members (limit) VALUES
	(100000),
	(80000),
	(1000000),
	(10000000),
	(500000);

CREATE OR REPLACE FUNCTION adicionar_transacao(id_cliente INT, kind CHAR(1), amount NUMERIC, description VARCHAR)
	RETURNS TABLE (novo_current_balance INT, novo_limit INT, validation_error BOOLEAN) AS $$
DECLARE
    diff INT;
    limit_cliente INT;
    current_balance_cliente INT;
BEGIN
		IF kind = 'd' THEN
        diff := amount * -1;
    ELSE
        diff := amount;
    END IF;

			PERFORM pg_advisory_xact_lock(id_cliente);
			SELECT 
				c.limit,
				COALESCE(c.current_balance, 0)
			INTO
				limit_cliente,
				current_balance_cliente
			FROM members c
			WHERE c.id = id_cliente;

		IF (current_balance_cliente + diff) < (-1 * limit_cliente) THEN
				RETURN QUERY SELECT current_balance_cliente as novo_current_balance, limit_cliente as novo_limit, true as validation_error;
		ELSE 
			UPDATE members 
			SET current_balance = current_balance + diff 
			WHERE id = id_cliente;

			INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (id_cliente, amount, kind, description);

			RETURN QUERY SELECT (current_balance_cliente + diff) as novo_current_balance, limit_cliente as novo_limit, false as validation_error;
		END IF;
		
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION balance(p_id integer)
RETURNS json AS $$
DECLARE
    result json;
    row_count integer;
    v_current_balance numeric;
    v_limit numeric;
BEGIN
    SELECT current_balance, limit
    INTO v_current_balance, v_limit
    FROM members
    WHERE id = p_id;

    SELECT json_build_object(
        'current_balance', json_build_object(
            'total', v_current_balance,
            'date_balance', NOW(),
            'limit', v_limit
        ),
        'recent_transactions', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT amount, kind, description, submitted_at
                FROM transactions
                WHERE cliente_id = p_id
                ORDER BY submitted_at DESC
                LIMIT 10
            ) t
        ), '[]')
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql;