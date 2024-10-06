SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET check_function_bodies = false;
SET row_security = off;
SET default_table_access_method = heap;

CREATE UNLOGGED TABLE cliente (
    id SERIAL PRIMARY KEY,
    current_balance integer NOT NULL,
    limit integer NOT NULL
);

CREATE UNLOGGED TABLE transacao (
    id SERIAL PRIMARY KEY,
    amount integer NOT NULL,
    kind varchar(1) NOT NULL,
    description varchar(10) NOT NULL,
    submitted_at timestamp NOT NULL DEFAULT (now()),
    cliente_id integer NOT NULL
);

CREATE INDEX idx_cliente_id ON transacao(cliente_id);
CREATE INDEX idx_submitted_at ON transacao(submitted_at);

INSERT INTO cliente (id, limit, current_balance) VALUES (1, 100000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (2, 80000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (3, 1000000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (4, 10000000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (5, 500000, 0);

CREATE OR REPLACE FUNCTION criar_transacao(cliente_id integer, amount integer, description varchar(10), kind varchar(1))
    RETURNS TABLE (current_balanceR integer, limitR integer) AS $$

    DECLARE current_balanceNovo integer;
    clienteASerAtualizado cliente%rowtype;
    clienteR cliente%rowtype;

BEGIN
SELECT * FROM cliente INTO clienteASerAtualizado WHERE id = cliente_id FOR UPDATE;

IF not found THEN
        RAISE EXCEPTION 'cliente nao encontrado';
END IF;

    IF kind = 'd' THEN
        IF clienteASerAtualizado.current_balance + clienteASerAtualizado.limit >= amount THEN
            current_balanceNovo := clienteASerAtualizado.current_balance - amount;
ELSE
            RAISE EXCEPTION 'nao possui limit';
END IF;
ELSE
        current_balanceNovo := clienteASerAtualizado.current_balance + amount;
END IF;

UPDATE cliente SET current_balance = current_balanceNovo WHERE id = cliente_id RETURNING * INTO clienteR;

INSERT INTO transacao (cliente_id, amount, kind, description) VALUES (cliente_id, amount, kind, description);

RETURN QUERY SELECT clienteR.current_balance, clienteR.limit;
END;
$$ LANGUAGE plpgsql;