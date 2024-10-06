SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_table_access_method = heap;

create unlogged table public.members
(
    id serial not null,
    nome varchar(100) not null,
    limit integer not null,
    current_balance integer not null,
    constraint pk_members primary key(id)
);

create unlogged table public.transactions
(
    id serial not null,
    amount integer not null,
    cliente_id integer not null,
    kind integer not null,
    description varchar(10) not null,    
    submitted_at timestamp not null default (now() at time zone 'utc'),
    constraint pk_transactions primary key(id)
);


create index ix_transactions_cliente_id on transactions(cliente_id asc);

-------------------------- proc criar_transacao --------------------------
create or replace procedure public.criar_transacao
( 
	cliente_id integer,
	amount integer,
	kind integer,
	description varchar(10),
	inout "ClienteId" integer default null,
	inout "Limite" integer default null,
	inout "Saldo" integer default null,
    inout "TransacaoFoiCriada" boolean default false
)
language plpgsql
as $proc$
begin
    select
        c.id
    from
        public.members c
        into "ClienteId"
    where
        c.id = cliente_id;
    
    if "ClienteId" is null then
        select
            0, 0, 0, false
        into "ClienteId", "Limite", "Saldo", "TransacaoFoiCriada";
        return;
    end if;
    
    update public.members
        set current_balance =
            case
                when kind = 1 then current_balance + amount
                else current_balance + amount * -1
            end
        where id = cliente_id and
        (
            case
                when kind = 1 then true
                else
                    (abs(current_balance + (amount * -1)) <= limit)
                end
        ) = true
        returning limit, current_balance
        into "Limite", "Saldo";
    
    if "Limite" is null then
        select
            "ClienteId", 0, 0, false
        into "ClienteId", "Limite", "Saldo", "TransacaoFoiCriada";
        return;
    end if;
    
    insert into public.transactions
        (amount, kind, description, cliente_id)
    values
        (
            amount,
            kind,
            description,
            cliente_id
        );    
    select
        "ClienteId","Limite", "Saldo", true
        into "ClienteId", "Limite", "Saldo", "TransacaoFoiCriada";
end
$proc$;

-------------------------- vw_balance --------------------------
create materialized view public.vw_balance
as
select
    j.id,
    json_build_object
    (
        'current_balance',
        json_build_object
        (
            'limit',
            j.limit,

            'total',
            j.total,

            'date_balance',
            to_char(j.date_balance, 'YYYY-MM-DD"T"HH24:MI:US"Z"')
        ),

        'recent_transactions',
        coalesce(j.recent_transactions, '{}')
    ) as balance
from
    (
        select
            c.id,
            c.current_balance as total,
            c.limit,
            now() at time zone 'utc' as date_balance,
            (
                select
                    array_agg(t)
                from
                    (

                        select
                            t.amount,
                            t.description,
                            to_char(t.submitted_at, 'YYYY-MM-DD"T"HH24:MI:US"Z"') as submitted_at,
                            case
                                when t.kind = 1 then 'c'
                                else 'd'
                            end as kind
                        from
                            public.transactions t
                        where
                            t.cliente_id = c.id
                        order by
                            t.submitted_at desc
                            limit 10

                    ) as t
            ) as recent_transactions
        from
            public.members c

    ) j
with data;
create unique index if not exists ix_vw_balance_id on public.vw_balance (id);

-------------------------- carga inicial --------------------------
DO $$
begin
insert into public.members (id, nome, current_balance, limit)
values
    (1, 'o barato sai caro', 0, 100000),
    (2, 'zan corp ltda', 0, 80000),
    (3, 'les cruders', 0, 1000000),
    (4, 'padaria joia de cocaia', 0, 10000000),
    (5, 'kid mais', 0, 500000);
    refresh materialized view public.vw_balance;
end; $$


