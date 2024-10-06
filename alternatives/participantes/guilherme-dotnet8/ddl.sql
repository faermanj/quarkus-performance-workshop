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

DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS transacao;

CREATE TABLE cliente (
  id SERIAL PRIMARY KEY,
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE transacao(
    id SERIAL PRIMARY KEY,
    amount  INTEGER NOT NULL,
    description VARCHAR(10) NOT NULL,
    kind CHAR NOT NULL,
    hora_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INTEGER NOT NULL
);

CREATE INDEX idx_customer_id ON cliente(id);

CREATE INDEX idx_transaction_customer_id ON transacao(id_cliente);

INSERT INTO cliente (limit, current_balance)
VALUES
    (1000 * 100, 0),
    (800 * 100, 0),
    (10000 * 100, 0),
    (100000 * 100, 0),
    (5000 * 100, 0);


CREATE TYPE current_balance_limit AS (
    current_balance_cliente int4,
    limit_cliente int4,
    success bool
);

CREATE OR REPLACE FUNCTION criar_transacao_debito(amount INTEGER, id_cliente int4, description varchar(10))
RETURNS current_balance_limit
LANGUAGE plpgsql 
AS $$
DECLARE
    result current_balance_limit;
BEGIN
   UPDATE cliente SET current_balance = current_balance - amount WHERE id = id_cliente AND current_balance - amount >= limit * (-1)
   RETURNING current_balance, limit INTO result.current_balance_cliente, result.limit_cliente;
   
   IF result.current_balance_cliente >= result.limit_cliente * (-1) then
   		result.success := true;
		INSERT INTO transacao (amount, kind, description,  id_cliente)
		VALUES(amount, 'd', description, id_cliente);
	else
		result.success := false;
   END IF;
   
   RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION criar_transacao_credito(amount INTEGER, id_cliente int4, description varchar(10))
RETURNS current_balance_limit
LANGUAGE plpgsql 
AS $$
DECLARE
    result current_balance_limit;
BEGIN
   UPDATE cliente SET current_balance = current_balance + amount WHERE id = id_cliente
   RETURNING current_balance, limit INTO result.current_balance_cliente, result.limit_cliente;

   result.success := true;
   
   INSERT INTO transacao (amount, kind, description,  id_cliente)
   VALUES(amount, 'c', description, id_cliente);
   
   RETURN result;
END;
$$;