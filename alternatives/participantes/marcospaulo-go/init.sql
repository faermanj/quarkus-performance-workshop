CREATE UNLOGGED TABLE clientes
(
    id     INT PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance  INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions
(
    id           SERIAL PRIMARY KEY,
    cliente_id   INTEGER     NOT NULL,
    amount        INTEGER     NOT NULL,
    kind         CHAR(1)     NOT NULL,
    description    VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP   NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_transactions_clientes_id
        FOREIGN KEY (cliente_id) REFERENCES clientes (id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);

CREATE INDEX idx_transactions_cliente_id_submitted_at ON transactions (cliente_id, submitted_at desc);

CREATE INDEX idx_transactions_submitted_at ON transactions (submitted_at desc);


CREATE OR REPLACE FUNCTION creditar(cliente_id_p int, amount_p integer, description_p varchar(10))
    RETURNS TABLE
            (
                current_balance_r  integer,
                limit_r integer
            )
AS
$$
DECLARE
    current_balance_atual  INTEGER;
    limit_atual INTEGER;
    novo_current_balance   INTEGER;
BEGIN

    PERFORM pg_advisory_xact_lock(cliente_id_p);

    SELECT current_balance, limit INTO current_balance_atual, limit_atual FROM clientes WHERE id = cliente_id_p;

    INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at)
    VALUES (cliente_id_p, amount_p, 'c', description_p, now());

    novo_current_balance := current_balance_atual + amount_p;

    UPDATE clientes SET current_balance = novo_current_balance WHERE id = cliente_id_p;

    return query select novo_current_balance, limit_atual;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION debitar(cliente_id_p int, amount_p integer, description_p varchar(10))
    RETURNS TABLE
            (
                current_balance_r  integer,
                limit_r integer,
                status_r integer
            )
AS
$$
DECLARE
    current_balance_atual  INTEGER;
    limit_atual INTEGER;
    novo_current_balance   INTEGER;
BEGIN


    PERFORM pg_advisory_xact_lock(cliente_id_p);

    SELECT limit, current_balance INTO limit_atual, current_balance_atual FROM clientes WHERE id = cliente_id_p;

    IF (current_balance_atual - amount_p < limit_atual * -1) THEN
        return query select 0, 0, 1;
        --RAISE EXCEPTION 'Valor ultrapassa o limit+current_balance';
    ELSE

        INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at)
        VALUES (cliente_id_p, amount_p, 'd', description_p, now());

        novo_current_balance := current_balance_atual - amount_p;

        UPDATE clientes SET current_balance = novo_current_balance WHERE id = cliente_id_p;
    
        return query select novo_current_balance, limit_atual, 0;

    END IF;

END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION limpar_transactions()
    RETURNS trigger AS
$$
DECLARE
  row_count int;
BEGIN

    DELETE
    FROM transactions
    WHERE cliente_id = NEW.cliente_id
      AND id NOT IN (SELECT id FROM transactions WHERE cliente_id = NEW.cliente_id ORDER BY submitted_at DESC LIMIT 10);

    IF found THEN
        GET DIAGNOSTICS row_count = ROW_COUNT;
        RAISE NOTICE 'DELETED % row(s) FROM transactions', row_count;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE TRIGGER trigger_delete_transactions
    AFTER INSERT
    ON transactions
    FOR EACH ROW
EXECUTE FUNCTION limpar_transactions();


DO
$$
    BEGIN
        INSERT INTO clientes (id, limit)
        VALUES (1, 100000),
               (2, 80000),
               (3, 1000000),
               (4, 10000000),
               (5, 500000);
    END;
$$
