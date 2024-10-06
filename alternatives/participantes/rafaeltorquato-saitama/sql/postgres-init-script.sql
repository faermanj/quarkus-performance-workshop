-- drop database if exists rinha;
-- create database rinha;
-- \c rinha

drop schema if exists rinha CASCADE;
create schema rinha;

-- Ao usar unlogged table, a tabela fica vulnerável a um crash no banco e os dados serem perdidos.
-- Use com cautela.
create unlogged table rinha.cliente
(
    id     smallint primary key,
    limit int not null,
    current_balance  int not null
);

-- Ao usar unlogged table, a tabela fica vulnerável a um crash no banco e os dados serem perdidos.
-- Use com cautela.
create unlogged table rinha.transacao
(
    id_cliente   smallint     not null,
    amount        int          not null,
    kind         char         not null,
    description    varchar(10)  not null,
    submitted_at timestamp(6) not null default current_timestamp(6)
);

create index idx_id_clientesubmitted_at
    on rinha.transacao (id_cliente, submitted_at desc);

drop procedure if exists rinha.processa_transacao;

create procedure rinha.processa_transacao(in in_id_cliente int,
                                          in in_amount int,
                                          in in_description varchar(10),
                                          in in_kind char,
                                          out out_current_balance json)
as
$$
declare
    _amount int;
begin
    if in_kind = 'd' then
        _amount := in_amount * -1;
    else
        _amount := in_amount;
    end if;
    with atualizar AS (
        update
            rinha.cliente c
                set current_balance = c.current_balance + _amount
                where c.id = in_id_cliente
                    and (in_kind = 'c' or (c.current_balance + _amount) >= (c.limit * -1))
                returning json_build_object('current_balance', current_balance, 'limit', limit) object)
    select object
    into out_current_balance
    from atualizar;

    if out_current_balance is not null then
        insert into rinha.transacao(amount, description, id_cliente, kind)
        values (in_amount, in_description, in_id_cliente, in_kind);
    end if;
end ;
$$ language plpgsql;

drop procedure if exists rinha.retorna_balance;
create procedure rinha.retorna_balance(in in_id_cliente int,
                                       out out_balance json)
as
$$
declare
    _current_balance_json      json;
    _transactions_json json;
    _date_balance    timestamp(6);
begin
    _date_balance := current_timestamp(6);
    select json_build_object('total', c.current_balance, 'limit', c.limit, 'date_balance',
                             to_char(_date_balance, 'yyyy-mm-dd"T"HH24:MI:SS.MS'))
    into _current_balance_json
    from rinha.cliente c
    where c.id = in_id_cliente;

    select json_agg(x.object)
    into _transactions_json
    from (select json_build_object('amount',
                                   t.amount,
                                   'kind',
                                   t.kind,
                                   'description',
                                   t.description,
                                   'submitted_at',
                                   to_char(t.submitted_at, 'yyyy-mm-dd"T"HH24:MI:SS.MS')) object

          from rinha.transacao t
          where t.id_cliente = in_id_cliente
          order by t.submitted_at desc
          limit 10) x;

    if _transactions_json is null then
        _transactions_json := json_build_array();
    end if;
    out_balance := json_build_object('current_balance', _current_balance_json,
                                     'recent_transactions', _transactions_json);
end;

$$ language plpgsql;

insert into rinha.cliente (id, limit, current_balance)
values (1, 100000, 0),
       (2, 80000, 0),
       (3, 1000000, 0),
       (4, 10000000, 0),
       (5, 500000, 0);

CREATE EXTENSION pg_prewarm;
