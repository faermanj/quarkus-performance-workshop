SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

SET default_tablespace = '';

SET default_table_access_method = heap;

DROP TABLE IF EXISTS public.clientes;

CREATE UNLOGGED TABLE public.clientes (
    cliente_id serial not null,
    nome varchar(32) not null,
    data_criacao timestamp not null default current_timestamp,
    limit bigint not null,
    current_balance bigint not null default 0,
    versao bigint not null default 0,
    primary key (cliente_id)
);

CREATE UNLOGGED TABLE public.transactions (
    id serial not null,
    cliente_id int not null,
    submitted_at timestamp not null default current_timestamp,
    amount bigint not null,
    kind char not null,
    description varchar(10) null,
    primary key (id)
);

CREATE INDEX idx_transactions_id_cliente ON transactions
(
    cliente_id ASC
);

  INSERT INTO public.clientes (nome, limit)
  VALUES
    ('o barato sai caro', 100000),
    ('zan corp ltda', 80000),
    ('les cruders', 1000000),
    ('padaria joia de cocaia', 10000000),
    ('kid mais', 500000);

