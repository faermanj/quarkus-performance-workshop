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

CREATE UNLOGGED TABLE current_balance_cliente (
    id SERIAL PRIMARY KEY NOT NULL,
    id_cliente INTEGER NOT NULL,
    current_balance INTEGER NOT NULL,
    limit INTEGER NOT NULL
);
CREATE UNIQUE INDEX idx_cliente_id_cliente ON current_balance_cliente (id_cliente);

CREATE UNLOGGED TABLE transacao_cliente (
    id SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC')
);
CREATE INDEX idx_transacao_cliente_id_cliente ON transacao_cliente (id_cliente);

DO $$
    BEGIN
        INSERT INTO current_balance_cliente (id_cliente, current_balance, limit)
        VALUES (1, 0,   1000 * 100),
               (2, 0,    800 * 100),
               (3, 0,  10000 * 100),
               (4, 0, 100000 * 100),
               (5, 0,   5000 * 100);
    END;
$$;

CREATE OR REPLACE FUNCTION atualiza_current_balance_cliente_and_insere_transacao(
    p_id_cliente INT,
    p_amount INT,
    p_description VARCHAR(10),
    p_kind CHAR(1))
    RETURNS TABLE (current_balance_atualizado INT, limit_atual INT, linhas_afetadas INT)
AS $$
DECLARE
    v_current_balance INT = 0;
    v_limit INT = 0;
    v_linhas_afetadas INT = 0;
BEGIN

    PERFORM pg_advisory_xact_lock(p_id_cliente);
    SELECT current_balance, limit INTO v_current_balance, v_limit FROM current_balance_cliente WHERE id_cliente = p_id_cliente;

    IF p_kind = 'c' THEN
        v_current_balance = v_current_balance + p_amount;
        UPDATE current_balance_cliente SET current_balance = v_current_balance WHERE id_cliente = p_id_cliente;
        GET diagnostics v_linhas_afetadas = row_count;
    ELSE
        v_current_balance = v_current_balance - p_amount;
        UPDATE current_balance_cliente SET current_balance = v_current_balance WHERE id_cliente = p_id_cliente AND abs(current_balance - p_amount) <= limit;
        GET diagnostics v_linhas_afetadas = row_count;
    END IF;

    IF v_linhas_afetadas > 0 THEN
        INSERT INTO transacao_cliente(id_cliente, amount, kind, description, submitted_at)
        VALUES (p_id_cliente, p_amount, p_kind, p_description, NOW());
    END IF;

    -- RETURN QUERY SELECT v_current_balance, v_limit, v_linhas_afetadas;
    RETURN QUERY SELECT current_balance AS current_balance_atualizado, limit AS limit_atual, v_linhas_afetadas AS linhas_afetadas FROM current_balance_cliente WHERE id_cliente = p_id_cliente;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obter_balance_cliente(p_id_cliente INT)
    RETURNS TABLE (
                      limit INT,
                      amount INT,
                      kind CHAR(1),
                      description VARCHAR(10),
                      data TIMESTAMP)
    LANGUAGE sql
AS $$
(SELECT limit       AS limit
      , current_balance        AS amount
      , NULL         AS kind
      , NULL         AS description
      , NOW()        AS data
 FROM current_balance_cliente
 WHERE id_cliente = p_id_cliente
 LIMIT 1)
UNION ALL
(SELECT NULL         AS limit
      , amount        AS amount
      , kind         AS kind
      , description    AS description
      , submitted_at AS data
 FROM transacao_cliente
 WHERE id_cliente = p_id_cliente
 ORDER BY id DESC
 LIMIT 10)
$$;