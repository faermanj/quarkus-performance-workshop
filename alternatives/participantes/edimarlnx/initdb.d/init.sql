drop table if exists clientes;
create table clientes
(
    id           serial NOT NULL primary key,
    current_balance        int    not null,
    limit       int    not null,
    date_balance timestamp WITH TIME ZONE not null default CURRENT_TIMESTAMP
);
drop table if exists transactions;
create table transactions
(
    id           serial  NOT NULL primary key,
    cliente_id   integer NOT NULL REFERENCES clientes (id),
    amount        int     not null,
    kind         char(1)     not null,
    description    varchar(10),
    submitted_at timestamp WITH TIME ZONE not null default CURRENT_TIMESTAMP
);

create index transactions_cliente_id_realizado_em ON transactions
    USING btree (cliente_id, submitted_at);

insert into clientes
    (id, current_balance, limit)
VALUES (1, 0, 100000),
       (2, 0, 80000),
       (3, 0, 1000000),
       (4, 0, 10000000),
       (5, 0, 500000);
