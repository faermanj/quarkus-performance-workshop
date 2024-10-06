-- inspired/stolen from that guy that knows alot of c# but I forgot the name
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

CREATE UNLOGGED TABLE pessoas (
    id int NOT NULL PRIMARY KEY,
    limit int NOT NULL CHECK (limit > 0),
    current_balance int NOT NULL,
    CHECK (current_balance > -limit)
);

CREATE UNLOGGED TABLE transactions (
    pessoa_id int NOT NULL,
    amount int NOT NULL,
    kind varchar(1) NOT NULL,
    description varchar(10) NOT NULL,
    submitted_at timestamp NOT NULL
);

CREATE INDEX idx_transactions_pessoa_id ON transactions (pessoa_id, submitted_at DESC);

INSERT INTO pessoas (id, limit, current_balance) VALUES (1, 100000, 0);
INSERT INTO pessoas (id, limit, current_balance) VALUES (2, 80000, 0);
INSERT INTO pessoas (id, limit, current_balance) VALUES (3, 1000000, 0);
INSERT INTO pessoas (id, limit, current_balance) VALUES (4, 10000000, 0);
INSERT INTO pessoas (id, limit, current_balance) VALUES (5, 500000, 0);

CREATE OR REPLACE PROCEDURE SALVAR_TRANSACAO(
    id_pessoa int,
    kind varchar(1),
    amount int,
    description varchar(10),
    INOUT resultado varchar(255)
)
LANGUAGE plpgsql
AS $$
DECLARE
    var_novo_current_balance int;
    var_atual_limit int;
BEGIN
    IF kind = 'c' THEN
        UPDATE pessoas
            SET
                current_balance = current_balance + amount,
                limit = limit
            WHERE id = id_pessoa
            RETURNING current_balance, limit
                INTO var_novo_current_balance, var_atual_limit;
    ELSE
        UPDATE pessoas
            SET
                current_balance = current_balance - amount,
                limit = limit
            WHERE id = id_pessoa
            RETURNING current_balance, limit
                INTO var_novo_current_balance, var_atual_limit;
    END IF;

    IF NOT FOUND THEN
        resultado = '-1';
        RETURN;
    ELSE
        INSERT INTO transactions (pessoa_id, amount, kind, description, submitted_at)
            VALUES (id_pessoa, amount, kind, description, CURRENT_TIMESTAMP);

        COMMIT;
        resultado = CONCAT(var_novo_current_balance::varchar, ':', var_atual_limit::varchar);
    END IF;
END;
$$;
