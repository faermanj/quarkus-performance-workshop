-- Database Schema
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    nome VARCHAR(256),
    current_balance INTEGER NOT NULL DEFAULT 0
);
CREATE TYPE kindTransacao as ENUM ('c', 'd');
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    kind kindTransacao NOT NULL,
    amount INTEGER NOT NULL,
    description VARCHAR(1024),
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX CONCURRENTLY transactions_submitted_at_idx ON transactions(cliente_id, submitted_at DESC);
CREATE FUNCTION updateClienteSaldoOnTransactionInsert() RETURNS trigger AS $updateClienteSaldoOnTransactionInsert$
    BEGIN 
        LOCK TABLE clientes IN ROW EXCLUSIVE MODE;
        PERFORM * FROM clientes WHERE clientes.id = NEW.cliente_id FOR UPDATE;
        IF NEW.kind = 'd' THEN
            IF (SELECT c.current_balance - NEW.amount < - c.limit from clientes c WHERE c.id = NEW.cliente_id) = TRUE THEN 
                RAISE EXCEPTION 'Saldo e limit indisponivel para realizar transacao';
            ELSE  UPDATE clientes SET current_balance = current_balance - NEW.amount WHERE id = NEW.cliente_id;
            END IF;
        END IF;
        IF NEW.kind = 'c' THEN
            UPDATE 
                clientes
            SET 
                current_balance = current_balance + NEW.amount
            WHERE id = NEW.cliente_id;
        END IF;
        RETURN NEW;
END;
$updateClienteSaldoOnTransactionInsert$ LANGUAGE plpgsql;
CREATE TRIGGER updateClienteSaldoOnTransactionInsert BEFORE
INSERT ON transactions FOR EACH ROW EXECUTE FUNCTION updateClienteSaldoOnTransactionInsert();

-- Initial Data
INSERT INTO clientes (nome, limit)
VALUES
('o barato sai caro', 1000 * 100),
('zan corp ltda', 800 * 100),
('les cruders', 10000 * 100),
('padaria joia de cocaia', 100000 * 100),
('kid mais', 5000 * 100);
