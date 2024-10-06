DROP DATABASE IF EXISTS "rinhadb";
CREATE DATABASE "rinhadb";

\c rinhadb;

CREATE UNLOGGED TABLE clients (
    id INT UNIQUE NOT NULL,
    limit INT, 
    balance INT,
    PRIMARY KEY(id)
);


CREATE UNLOGGED TABLE transactions1 (
    id SERIAL,
    amount INT NOT NULL,
    kind VARCHAR(10),
    description VARCHAR(10) NOT NULL,
    submitted_at timestamptz NULL
);

CREATE UNLOGGED TABLE transactions2 (
    id SERIAL,
    client_id INT,
    amount INT NOT NULL,
    kind VARCHAR(10),
    description VARCHAR(10) NOT NULL,
    submitted_at timestamptz NULL
);

CREATE UNLOGGED TABLE transactions3 (
    id SERIAL,
    client_id INT,
    amount INT NOT NULL,
    kind VARCHAR(10),
    description VARCHAR(10) NOT NULL,
    submitted_at timestamptz NULL
);

CREATE UNLOGGED TABLE transactions4 (
    id SERIAL,
    client_id INT,
    amount INT NOT NULL,
    kind VARCHAR(10),
    description VARCHAR(10) NOT NULL,
    submitted_at timestamptz NULL
);

CREATE UNLOGGED TABLE transactions5 (
    id SERIAL,
    client_id INT,
    amount INT NOT NULL,
    kind VARCHAR(10),
    description VARCHAR(10) NOT NULL,
    submitted_at timestamptz NULL
);

INSERT INTO "clients"("id", "limit", "balance") VALUES
    (1, 100000, 0),
    (2, 80000, 0),
    (3, 1000000, 0),
    (4, 10000000, 0),
    (5, 500000, 0);

CREATE OR REPLACE FUNCTION FindClient(idClient INT) 
RETURNS clients
LANGUAGE sql 
AS $$
    SELECT * FROM clients WHERE id = idClient FOR UPDATE;
$$
;


CREATE OR REPLACE FUNCTION add_transaction(idClient INT, amount INT, kind CHAR, description VARCHAR(10))
RETURNS INT
LANGUAGE 'plpgsql'
AS $$
DECLARE
    novo_current_balance INT;
BEGIN
    IF kind = 'c' THEN
        UPDATE clients SET balance = balance + amount WHERE id = idClient
        RETURNING balance INTO novo_current_balance;
    ELSE
        UPDATE clients SET balance = balance - amount WHERE id = idClient AND balance - amount  >= limit * -1
        RETURNING balance INTO novo_current_balance;
    END IF;

    IF novo_current_balance IS NOT NULL THEN
        case idClient
            WHEN 1 THEN
                INSERT INTO transactions1(amount, kind, description, submitted_at)
                VALUES (amount, kind, description, now());
            WHEN 2 THEN
                INSERT INTO transactions2(amount, kind, description, submitted_at)
                VALUES (amount, kind, description, now());
            WHEN 3 THEN
                INSERT INTO transactions3(amount, kind, description, submitted_at)
                VALUES (amount, kind, description, now());
            WHEN 4 THEN
                INSERT INTO transactions4(amount, kind, description, submitted_at)
                VALUES (amount, kind, description, now());
            ELSE
                INSERT INTO transactions5(amount, kind, description, submitted_at)
                VALUES (amount, kind, description, now());
            END CASE;
    END IF;

    RETURN novo_current_balance;
END
$$;

-- Esquentando o banco pra diminuir o tempo inicial das requisicoes
-- Referencia do pq isso funciona https://littlekendra.com/2016/11/25/why-is-my-query-faster-the-second-time-it-runs-dear-sql-dba-episode-23/
SELECT * FROM clients;
SELECT * FROM transactions1;
SELECT * FROM transactions2;
SELECT * FROM transactions3;
SELECT * FROM transactions4;
SELECT * FROM transactions5;

SELECT * FROM add_transaction(1, 10, 'c', 'primeira');
SELECT * FROM transactions1;
SELECT * FROM add_transaction(2, 10, 'c', 'primeira');
SELECT * FROM transactions2;
SELECT * FROM add_transaction(3, 10, 'c', 'primeira');
SELECT * FROM transactions3;
SELECT * FROM add_transaction(4, 10, 'c', 'primeira');
SELECT * FROM transactions4;
SELECT * FROM add_transaction(5, 10, 'c', 'primeira');
SELECT * FROM transactions5;

DELETE FROM transactions1;
DELETE FROM transactions2;
DELETE FROM transactions3;
DELETE FROM transactions4;
DELETE FROM transactions5;

UPDATE clients SET balance=0;