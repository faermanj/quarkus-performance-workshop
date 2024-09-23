create table public.members
(
    id          integer not null,
    limite      integer not null,
    saldo_atual integer not null,
    saldo_inicial
                integer not null,
    primary key (id)
);

create table public.transactions
(
    id         serial       not null,
    id_cliente integer      not null,
    valor      integer      not null,
    realizada_em
               timestamp(6) not null,
    descricao  varchar(255) not null,
    tipo       varchar(255) not null check (tipo in ('c', 'd')),
    primary key (id)
);

create sequence public.cliente_seq start with 1 increment by 10;

alter table if exists public.transactions
    add constraint FK_cliente foreign key (id_cliente) references public.members;

INSERT INTO public.members (id, limite, saldo_inicial, saldo_atual)
VALUES (1, 100000, 0, 0),
       (2, 80000, 0, 0),
       (3, 1000000, 0, 0),
       (4, 10000000, 0, 0),
       (5, 500000, 0, 0);
