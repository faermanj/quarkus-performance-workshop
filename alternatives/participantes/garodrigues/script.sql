CREATE UNLOGGED TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cliente_id ON transactions(cliente_id);

INSERT INTO clients (limit, current_balance) 
VALUES
    (100000, 0),
    (80000, 0),
    (1000000, 0),
    (10000000, 0),
    (50000, 0);

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
