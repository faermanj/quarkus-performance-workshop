-- public.conta_corrente definition

-- Drop table

-- DROP TABLE public.contacorrente;

CREATE TABLE public.contacorrente
(
    id     bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
    nome   varchar(255) NULL,
    current_balance  bigint NULL,
    limit bigint NULL,
    CONSTRAINT conta_corrente_pk PRIMARY KEY (id)
);

-- public.conta_corrente complete

-- public.movimentos definition

-- Drop table

-- DROP TABLE public.movimento;

CREATE TABLE public.movimento
(
    id             bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
    idcliente     bigint NULL,
    amount          bigint NULL,
    kind           varchar(1) NULL,
    description      varchar(10) NULL,
    datamovimento timestamp NULL,
    CONSTRAINT movimento_pk PRIMARY KEY (id)
);

-- DROP ROLE rinha;

-- DROP ROLE rinha;

-- CREATE ROLE rinha WITH
--     NOSUPERUSER
--     NOCREATEDB
--     NOCREATEROLE
--     NOINHERIT
--     LOGIN
--     NOREPLICATION
--     NOBYPASSRLS
--     CONNECTION LIMIT -1;

-- Permissions

GRANT INSERT, SELECT, REFERENCES, DELETE, TRUNCATE, UPDATE, TRIGGER ON TABLE public.contacorrente TO rinha;
GRANT INSERT, SELECT, REFERENCES, DELETE, TRUNCATE, UPDATE, TRIGGER ON TABLE public.movimento TO rinha;

ALTER USER rinha WITH PASSWORD 'backend';

create sequence public.contacorrente_seq increment by 1;
create sequence public.movimento_seq increment by 50;

alter table public.movimento owner to rinha;
alter table public.contacorrente owner to rinha;
alter sequence public.contacorrente_seq owner to rinha;
alter sequence public.movimento_seq owner to rinha;

INSERT INTO public.contacorrente (id, nome, current_balance, limit)
VALUES (1, 'odorico paraguaçu', 0, 100000),
       (2, 'irmas cajazeira', 0, 80000),
       (3, 'coronel nepomuceno', 0, 1000000),
       (4, 'dirceu borboleta', 0, 10000000),
       (5, 'zeca diabo', 0, 500000);