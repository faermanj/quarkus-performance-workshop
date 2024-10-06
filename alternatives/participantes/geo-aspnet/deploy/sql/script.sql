CREATE DATABASE RinhaBackend;

\c RinhaBackend;

CREATE UNLOGGED TABLE Clientes (
    Id serial,
    Limite int NOT NULL,
    Saldo int NOT NULL
);
 CREATE INDEX clientes_id_idx ON Clientes (Id);

INSERT INTO Clientes (Limite, Saldo)
VALUES
(100000, 0),
(80000, 0),
(1000000, 0),
(10000000, 0),
(500000, 0);

CREATE UNLOGGED TABLE transactions (
    Id SERIAL PRIMARY KEY,
    Cliente_Id INTEGER NOT NULL,
    Valor INTEGER NOT NULL,
    Tipo CHAR(1) NOT NULL,
    Descricao VARCHAR(10) NOT NULL,
    Realizada_Em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_transactions_cliente_id ON transactions (Cliente_Id);


CREATE OR REPLACE FUNCTION InserirTransacao(cliente_id INTEGER, amount INTEGER, kind CHAR, description TEXT)
RETURNS TABLE (limit INTEGER, current_balance INTEGER) AS $$
DECLARE
    current_limit INTEGER;
    current_current_balance INTEGER;
BEGIN    
    SELECT clientes.limit, clientes.current_balance INTO current_limit, current_current_balance FROM clientes WHERE id = cliente_id FOR UPDATE;

    IF kind = 'c' THEN
        current_current_balance := current_current_balance + amount;
    ELSE
        current_current_balance := current_current_balance - amount;
    END IF;

    IF current_current_balance < 0 AND ABS(current_current_balance) > current_limit THEN
        RETURN;
    ELSE    
        INSERT INTO transactions (Cliente_Id, Valor, Tipo, Descricao, Realizada_Em)
        VALUES (cliente_id, amount, kind, description, CURRENT_TIMESTAMP);

        UPDATE Clientes SET Saldo = current_current_balance WHERE Id = cliente_id;

        RETURN QUERY SELECT current_limit, current_current_balance;
    END IF;
END;
$$ LANGUAGE plpgsql;
