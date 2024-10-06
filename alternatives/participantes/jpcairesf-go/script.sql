create unlogged table if not exists  cliente (
    id serial primary key not null,
    limit integer not null,
    current_balance integer not null
);
create unlogged table if not exists transacao (
    id serial primary key not null,
    description varchar(10) not null,
    submitted_at timestamp(6) not null,
    kind char(1) not null,
    amount integer not null,
    cliente_id integer
);
create index if not exists CLIENTE_REALIZADA_EM_INDEX
   on transacao (cliente_id, submitted_at desc);
alter table if exists transacao
   add constraint FK6cqdtt28hwwinbxxayub0wftw
   foreign key (cliente_id)
   references cliente;

insert into cliente values
    ('1', '100000', '0'),
    ('2', '80000', '0'),
    ('3', '1000000', '0'),
    ('4', '10000000', '0'),
    ('5', '500000', '0');