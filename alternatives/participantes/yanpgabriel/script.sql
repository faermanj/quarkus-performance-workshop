create table public.members
(
    id          integer not null,
    limit      integer not null,
    current_balance_atual integer not null,
    current_balance_inicial
                integer not null,
    primary key (id)
);

create table public.transactions
(
    id         serial       not null,
    id_cliente integer      not null,
    amount      integer      not null,
    submitted_at
               timestamp(6) not null,
    description  varchar(255) not null,
    kind       varchar(255) not null check (kind in ('c', 'd')),
    primary key (id)
);

create sequence public.cliente_seq start with 1 increment by 10;

alter table if exists public.transactions
    add constraint FK_cliente foreign key (id_cliente) references public.members;

INSERT INTO public.members (id, limit, current_balance_inicial, current_balance_atual)
VALUES (1, 100000, 0, 0),
       (2, 80000, 0, 0),
       (3, 1000000, 0, 0),
       (4, 10000000, 0, 0),
       (5, 500000, 0, 0);
