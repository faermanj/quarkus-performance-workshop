CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    limit INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    data_transacao TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_clientes_transactions_id
        FOREIGN KEY (id_cliente) REFERENCES clientes(id)
);

CREATE UNLOGGED TABLE current_balances (
    id SERIAL NOT NULL,
    id_cliente INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    CONSTRAINT fk_clientes_current_balances_id
        FOREIGN KEY (id_cliente) REFERENCES clientes(id),
    PRIMARY KEY (id, id_cliente)
);

DO $$
BEGIN
    INSERT INTO clientes (nome, limit)
    VALUES
        ('Ivo Matias', 1000 * 100),
        ('Electra Costa', 800 * 100),
        ('Pilar Nascimento', 10000 * 100),
        ('Carmelina Vaz', 100000 * 100),
        ('Marco Vilar', 5000 * 100);

    INSERT INTO current_balances (id_cliente, amount)
        SELECT id, 0 FROM clientes;
END;
$$;

CREATE OR REPLACE FUNCTION debito (
    id_cliente_tx INT,
    amount_tx INT,
    description_tx VARCHAR(10)
)
RETURNS TABLE (
    novo_current_balance INT,
    limit INT,
    com_erro BOOL,
    mensagem VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    current_balance_atual INT;
    limit_atual INT;
BEGIN
    PERFORM pg_advisory_xact_lock(id_cliente_tx);
    SELECT
        c.limit,
        COALESCE(s.amount, 0)
    INTO
        limit_atual,
        current_balance_atual
    FROM
        clientes c
        LEFT JOIN current_balances s
            ON c.id = s.id_cliente
    WHERE
        c.id = id_cliente_tx;

    IF current_balance_atual - amount_tx >= limit_atual * -1 THEN
        INSERT INTO transactions
        VALUES
            (DEFAULT, id_cliente_tx, amount_tx, 'd', description_tx, NOW());

        UPDATE current_balances
        SET
            amount = amount - amount_tx
        WHERE
            id_cliente = id_cliente_tx;

        RETURN QUERY
            SELECT
                amount,
                limit_atual,
                FALSE,
                'OK'::VARCHAR(20)
            FROM
                current_balances
            WHERE
                id_cliente = id_cliente_tx;
    ELSE
        RETURN QUERY
            SELECT
                amount,
                limit_atual,
                TRUE,
                'current_balance insuficiente'::VARCHAR(20)
            FROM
                current_balances
            WHERE
                id_cliente = id_cliente_tx;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION credito (
    id_cliente_tx INT,
    amount_tx INT,
    description_tx VARCHAR(20)
)
RETURNS TABLE (
    novo_current_balance INT,
    limit INT,
    com_erro BOOL,
    mensagem VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    limit_atual INT;
BEGIN
    PERFORM pg_advisory_xact_lock(id_cliente_tx);

    SELECT c.limit
    INTO limit_atual
    FROM clientes c
    WHERE
        c.id = id_cliente_tx;
        
    INSERT INTO transactions
    VALUES
        (DEFAULT, id_cliente_tx, amount_tx, 'c', description_tx, NOW());

    RETURN QUERY
        UPDATE current_balances
        SET
            amount = amount + amount_tx
        WHERE
            current_balances.id_cliente = id_cliente_tx
        RETURNING
            amount, limit_atual, FALSE, 'OK'::VARCHAR(20);
END;
$$;

CREATE OR REPLACE FUNCTION reset_db ()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE current_balances
    SET
        amount = 0;

    TRUNCATE TABLE transactions;
END;
$$;

CREATE OR REPLACE FUNCTION public.balance(
	id_cliente_tx INT
)
RETURNS TABLE(
    balance jsonb
)
LANGUAGE SQL
AS $$
SELECT
	json_build_object(
		'amount', tx.amount,
		'kind', tx.kind,
		'description', tx.description,
		'submitted_at', tx.data_transacao
	)
FROM
	transactions tx
WHERE
	tx.id_cliente = id_cliente_tx
ORDER BY tx.id DESC
LIMIT 10;
$$;

