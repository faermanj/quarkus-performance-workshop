-- Based on https://github.com/eupassarin/rinha2/blob/master/init.sql by https://github.com/eupassarin/rinha2

ALTER DATABASE rinha_db;

CREATE UNLOGGED TABLE IF NOT EXISTS members (id SMALLINT NOT NULL, limit INTEGER NOT NULL, current_balance INTEGER NOT NULL DEFAULT 0);
CREATE INDEX IF NOT EXISTS pk_client_idx ON members (id) INCLUDE (current_balance);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (amount INTEGER NOT NULL,  kind CHAR(1) NOT NULL, description VARCHAR(10) NOT NULL, submitted_at timestamp without time zone DEFAULT now(), id_cliente SMALLINT NOT NULL);

CREATE INDEX IF NOT EXISTS CLIENT_IDX ON transactions (id_cliente);
CREATE INDEX IF NOT EXISTS REALIZADA_EM_IDX ON transactions (submitted_at DESC);

CREATE FUNCTION ADD_DEBIT(ID_CLIENTE SMALLINT, VALOR INT, DESCRICAO TEXT, P_LIMITE INT, OUT NOVO_SALDO INT) LANGUAGE plpgsql AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(ID_CLIENTE);

    UPDATE members SET current_balance = current_balance - VALOR
    WHERE id = ID_CLIENTE AND current_balance - VALOR >= - P_LIMITE
    RETURNING current_balance INTO NOVO_SALDO;

    IF NOVO_SALDO IS NULL THEN
        RETURN;
    END IF;

    INSERT INTO transactions (id_cliente, amount, kind, description)
    VALUES(ID_CLIENTE, amount, 'd', DESCRICAO);
END;
$$;

CREATE FUNCTION ADD_CREDIT(ID_CLIENTE SMALLINT, VALOR INT, DESCRICAO TEXT, OUT NOVO_SALDO INT) LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO transactions (id_cliente, amount, kind, description)
    VALUES(ID_CLIENTE, VALOR, 'c', DESCRICAO);

    PERFORM pg_advisory_xact_lock(ID_CLIENTE);
    UPDATE members SET current_balance = current_balance + amount
    WHERE id = ID_CLIENTE
    RETURNING current_balance INTO NOVO_SALDO;
END;
$$;

DO $$
BEGIN
    INSERT INTO members
    VALUES  (1, 1000 * 100, 0),
            (2, 800 * 100, 0),
            (3, 10000 * 100, 0),
            (4, 100000 * 100, 0),
            (5, 5000 * 100, 0);
END;
$$;
