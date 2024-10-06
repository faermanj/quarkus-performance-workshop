CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    idCliente INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    dataCriacao TIMESTAMP NOT NULL
);

INSERT INTO clientes (limit)
VALUES
  (1000 * 100),
  (800 * 100),
  (10000 * 100),
  (100000 * 100),
  (5000 * 100);

ALTER TABLE transactions
SET (autovacuum_enabled = false);

CREATE INDEX idx_transactions ON transactions (idCliente ASC);

CREATE OR REPLACE FUNCTION debitar(
    idClienteTx INTEGER,
    amountTx INT,
    descriptionTx VARCHAR(10))
RETURNS TABLE (
    novoSaldo INT,
    sucesso BOOL,
    limit INT)
LANGUAGE plpgsql
AS $$
DECLARE
    current_balanceAtual INT;
    limitAtual INT;
BEGIN
    PERFORM pg_advisory_xact_lock(idClienteTx);

    SELECT 
        clientes.limit,
        clientes.current_balance
    INTO
        limitAtual,
        current_balanceAtual
    FROM clientes
    WHERE id = idClienteTx;

    IF current_balanceAtual - amountTx >= limitAtual * -1 THEN
        INSERT INTO transactions VALUES(DEFAULT, idClienteTx, amountTx, 'd', descriptionTx, NOW());
        
        RETURN QUERY
        UPDATE clientes 
        SET current_balance = current_balance - amountTx 
        WHERE id = idClienteTx
        RETURNING current_balance, TRUE, limitAtual;
    ELSE
        RETURN QUERY SELECT current_balanceAtual, FALSE, limitAtual;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
    idClienteTx INTEGER,
    amountTx INT,
    descriptionTx VARCHAR(10))
RETURNS TABLE (
    novoSaldo INT,
    sucesso BOOL,
    limitAtual INT)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM pg_advisory_xact_lock(idClienteTx);

    INSERT INTO transactions VALUES(DEFAULT, idClienteTx, amountTx, 'c', descriptionTx, NOW());

    RETURN QUERY
        UPDATE clientes
        SET current_balance = current_balance + amountTx
        WHERE id = idClienteTx
        RETURNING current_balance, TRUE, clientes.limit;
END;
$$;
