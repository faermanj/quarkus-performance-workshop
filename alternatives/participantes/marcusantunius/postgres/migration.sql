SET enable_seqscan = off;

create unlogged table cliente
(
    id     integer primary key,
    limit bigint not null,
    current_balance  bigint not null default 0 check ( (abs(limit) - abs(current_balance)) > 0 )
);

insert into cliente (id, limit, current_balance)
values (1, 100000, 0),
       (2, 80000, 0),
       (3, 1000000, 0),
       (4, 10000000, 0),
       (5, 500000, 0);


create UNLOGGED table transacao
(
    id           serial primary key,
    cliente_id   integer references cliente (id),
    amount        bigint      not null,
    kind         char        not null,
    description    varchar(11) not null,
    realidada_em timestamp   not null default now()

);

create index on transacao (cliente_id);

ALTER TABLE cliente
    SET (autovacuum_enabled = false);

ALTER TABLE transacao
    SET (autovacuum_enabled = false);