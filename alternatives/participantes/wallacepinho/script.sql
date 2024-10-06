create schema rinha;

-- tables
create table rinha.cliente (
    id integer,
    limit integer,
    current_balance integer
);

create table rinha.transacao (
    cliente_id integer,
    amount integer,
    kind varchar(1),
    description varchar(10),
    submitted_at timestamp
);

-- data
insert into rinha.cliente(id, limit, current_balance) values 
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);