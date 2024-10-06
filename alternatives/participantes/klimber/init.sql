-- This file allow to write SQL commands that will be emitted in test and dev.
create UNLOGGED table Cliente (
    id serial primary key,
    limit bigint
);

create UNLOGGED table Transacao (
    id serial primary key,
    kind char(1),
    cliente_id bigint references Cliente,
    amount bigint,
    description varchar(255),
    submitted_at timestamp,
    current_balance bigint
);

insert into Cliente (id, limit) values (1, 100000),
                                        (2, 80000),
                                        (3, 1000000),
                                        (4, 10000000),
                                        (5, 500000);
