create table if not exists cliente (
    id integer constraint pk_cliente primary key,
    limit bigint not null,
    current_balance bigint not null,

    constraint chk_current_balance CHECK(current_balance >= (-limit))
);

create table if not exists transacao (
    id serial constraint pk_transacao primary key,
    id_cliente integer references cliente(id),
    amount integer not null,
    kind char not null,
    description character varying (10) not null,
    submitted_at timestamp not null default current_timestamp
);

create index CONCURRENTLY idx_transacao_id_cliente ON transacao (id_cliente);
create index CONCURRENTLY idx_transacao_submitted_at ON transacao (submitted_at DESC);

insert into cliente(id, limit, current_balance) values(1, 100000, 0);
insert into cliente(id, limit, current_balance) values(2, 80000, 0);
insert into cliente(id, limit, current_balance) values(3, 1000000, 0);
insert into cliente(id, limit, current_balance) values(4, 10000000, 0);
insert into cliente(id, limit, current_balance) values(5, 500000, 0);
