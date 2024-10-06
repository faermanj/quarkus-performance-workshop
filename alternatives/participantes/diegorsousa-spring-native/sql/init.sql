create table cliente (
    id bigserial not null,
    limit integer not null,
    current_balance integer not null,
    primary key (id)
);

create table transacao (
    id bigserial not null,
    description varchar(255),
    kind char(1),
    amount integer not null,
    cliente_id bigint,
    submitted_at timestamp(6),
    primary key (id),
    foreign key (cliente_id) references cliente(id)
);

create index transacao_fkey on public.transacao using btree (cliente_id);


insert into cliente (id, limit, current_balance)
values
    (1, 100000, 0),
    (2, 80000, 0),
    (3, 1000000, 0),
    (4, 10000000, 0),
    (5, 500000, 0);
