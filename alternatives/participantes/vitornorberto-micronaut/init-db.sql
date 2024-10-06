begin;
create table if not exists cliente
(
    id     SERIAL primary key,
    limit integer not null,
    current_balance  integer not null
);

CREATE INDEX idx_cliente_id ON cliente (id);
commit;

begin;
insert into cliente(id, limit, current_balance)
values (1, 100000, 0);
insert into cliente(id, limit, current_balance)
values (2, 80000, 0);
insert into cliente(id, limit, current_balance)
values (3, 1000000, 0);
insert into cliente(id, limit, current_balance)
values (4, 10000000, 0);
insert into cliente(id, limit, current_balance)
values (5, 500000, 0);
commit;

begin;
create table if not exists transacao
(
    id         SERIAL primary key,
    amount      integer                        not null,
    description  varchar(10)                    not null,
    data       timestamp                      not null,
    kind       char                           not null,
    cliente_id SERIAL references cliente (id) not null
);

CREATE INDEX idx_transactions_cliente_id ON transacao (cliente_id);

commit;