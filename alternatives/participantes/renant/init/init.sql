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
	limite INTEGER NOT NULL,
	saldo INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(255) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);


CREATE INDEX IF NOT EXISTS idx_cliente_id ON members(id);
CREATE INDEX IF NOT EXISTS idx_transacao_id_cliente_realizada_em_desc ON transactions(cliente_id, realizada_em DESC);

INSERT INTO members (limite) VALUES
	(100000),
	(80000),
	(1000000),
	(10000000),
	(500000);

CREATE OR REPLACE FUNCTION adicionar_transacao(id_cliente INT, tipo CHAR(1), valor NUMERIC, descricao VARCHAR)
	RETURNS TABLE (novo_saldo INT, novo_limite INT, validation_error BOOLEAN) AS $$
DECLARE
    diff INT;
    limite_cliente INT;
    saldo_cliente INT;
BEGIN
		IF tipo = 'd' THEN
        diff := valor * -1;
    ELSE
        diff := valor;
    END IF;

			PERFORM pg_advisory_xact_lock(id_cliente);
			SELECT 
				c.limite,
				COALESCE(c.saldo, 0)
			INTO
				limite_cliente,
				saldo_cliente
			FROM members c
			WHERE c.id = id_cliente;

		IF (saldo_cliente + diff) < (-1 * limite_cliente) THEN
				RETURN QUERY SELECT saldo_cliente as novo_saldo, limite_cliente as novo_limite, true as validation_error;
		ELSE 
			UPDATE members 
			SET saldo = saldo + diff 
			WHERE id = id_cliente;

			INSERT INTO transactions (cliente_id, valor, tipo, descricao) VALUES (id_cliente, valor, tipo, descricao);

			RETURN QUERY SELECT (saldo_cliente + diff) as novo_saldo, limite_cliente as novo_limite, false as validation_error;
		END IF;
		
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION extrato(p_id integer)
RETURNS json AS $$
DECLARE
    result json;
    row_count integer;
    v_saldo numeric;
    v_limite numeric;
BEGIN
    SELECT saldo, limite
    INTO v_saldo, v_limite
    FROM members
    WHERE id = p_id;

    SELECT json_build_object(
        'saldo', json_build_object(
            'total', v_saldo,
            'data_extrato', NOW(),
            'limite', v_limite
        ),
        'ultimas_transactions', COALESCE((
            SELECT json_agg(row_to_json(t)) FROM (
                SELECT valor, tipo, descricao, realizada_em
                FROM transactions
                WHERE cliente_id = p_id
                ORDER BY realizada_em DESC
                LIMIT 10
            ) t
        ), '[]')
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql;