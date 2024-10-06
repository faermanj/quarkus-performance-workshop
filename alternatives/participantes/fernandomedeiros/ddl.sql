--DDL
--create UNLOGGED table cliente (id bigserial not null, limit bigint, current_balance bigint, primary key (id));

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

CREATE UNLOGGED TABLE cliente (
	id INTEGER PRIMARY KEY,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL
);


CREATE UNLOGGED TABLE transacao (
    id SERIAL PRIMARY KEY,
    kind char(1) not null,
    amount numeric(10,0) NOT NULL,
    description varchar(10) NOT NULL,
    data_lancamento timestamp(6) NOT NULL,
    cliente_id integer NOT NULL,
    CONSTRAINT fk_transactions_members_id
           FOREIGN KEY (cliente_id) REFERENCES cliente (id)
);

CREATE INDEX idx_transactions_cliente_id ON transacao (cliente_id);

CREATE INDEX idx_transactions_cliente_id_submitted_at ON transacao (cliente_id, data_lancamento desc);

CREATE INDEX idx_transactions_submitted_at ON transacao (data_lancamento desc);

--DML
INSERT INTO public.cliente(	limit, current_balance, id) 	VALUES (100000, 0, 1);
INSERT INTO public.cliente(	limit, current_balance, id) 	VALUES (80000, 0, 2);
INSERT INTO public.cliente(	limit, current_balance, id) 	VALUES (1000000, 0, 3);
INSERT INTO public.cliente(	limit, current_balance, id) 	VALUES (10000000, 0, 4);
INSERT INTO public.cliente(	limit, current_balance, id) 	VALUES (500000, 0, 5);