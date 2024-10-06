CREATE TABLE clientes
(
    id     SERIAL,
    current_balance  INTEGER     NOT NULL,
    limit INTEGER     NOT NULL
);
CREATE INDEX ON clientes USING HASH(id);

CREATE UNLOGGED TABLE transactions
(
    id           SERIAL,
    cliente_id   INTEGER     NOT NULL,
    amount        INTEGER     NOT NULL,
    kind         CHAR(1)     NOT NULL,
    description    VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP   NOT NULL DEFAULT NOW()
);
CREATE INDEX ON transactions (id DESC);
CREATE INDEX ON transactions (cliente_id);
DO
$$
    BEGIN
        INSERT INTO clientes (limit, current_balance)
        VALUES (1000 * 100, 0),
               (800 * 100, 0),
               (10000 * 100, 0),
               (100000 * 100, 0),
               (5000 * 100, 0);
    END;
$$;

CREATE OR REPLACE PROCEDURE CREATE_TRANSACTION_DEBIT(cid integer, value integer, type char, description text, OUT newBalance integer, OUT climit integer)
AS
$$
DECLARE
    balance int4;
BEGIN
    SELECT current_balance, limit INTO balance, climit FROM clientes WHERE id = cid FOR UPDATE;
    newBalance = balance - value;
    IF -newBalance > climit THEN
        climit = -1;
        RETURN;
    END IF;
    UPDATE clientes SET current_balance = newBalance WHERE id = cid;
    INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (cid, value, type, description);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE CREATE_TRANSACTION_CREDIT(cid integer, value integer, type char, description text, INOUT newBalance integer, INOUT climit integer)
AS
$$
DECLARE
    balance int4;
BEGIN
    SELECT current_balance, limit INTO balance, climit FROM clientes WHERE id = cid FOR UPDATE;
    newBalance = balance + value;
    UPDATE clientes SET current_balance = newBalance WHERE id = cid;
    INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (cid, value, type, description);
END;
$$LANGUAGE plpgsql;