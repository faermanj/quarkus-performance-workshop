create table clientes (
    id serial primary key,
    limit integer,
    current_balance integer
);

create table transactions (
    id serial primary key,
    amount integer,
    kind varchar(1),
    description varchar(20),
    data_transacao timestamp,
    id_cliente integer references clientes(id)
);

create index on transactions (id_cliente);

insert into clientes (limit, current_balance) values (100000, 0);
insert into clientes (limit, current_balance) values (80000, 0);
insert into clientes (limit, current_balance) values (1000000, 0);
insert into clientes (limit, current_balance) values (10000000, 0);
insert into clientes (limit, current_balance) values (500000, 0);
