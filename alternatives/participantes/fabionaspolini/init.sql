create unlogged table cliente (
	id integer primary key not null,
    current_balance integer not null,
   	limit integer not null);
    
create unlogged table transacao (
    id serial primary key not null,
    cliente_id integer not null,
    kind char(1) not null,
    amount integer not null,
    submitted_at timestamptz not null,
    description varchar(10) not null);
   
create index ix_transacao_cliente_data on transacao(cliente_id, submitted_at desc);

insert into cliente(id, limit, current_balance) values
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);

create type inserir_transacao_result as (
	result_code int,
	result_message varchar(100),
	current_balance integer,
	limit integer);

/*
 * 0: OK
 * 1: Cliente inválido.
 * 2: Saldo e limit insuficiente para executar a operação.
 */

-- data type
create or replace function inserir_transacao_credito(
    cliente_id int,
    amount int,
    description varchar(10))
returns inserir_transacao_result as $func$
declare
    cli cliente%rowtype;
    result inserir_transacao_result;
begin
    /* Se for crédito, não valida estouro de limit*/
    update cliente
    set current_balance = current_balance + amount
    where id = cliente_id
    returning *
    into cli;
    
    if not found then
        select 1, 'Cliente inválido.', null, null into result;
        return result;
    end if;

    insert into transacao(cliente_id, kind, amount, submitted_at, description)
    values (cliente_id, 'c', amount, now(), description);

    select 0, null, cli.current_balance, cli.limit into result;
    return result;
end;
$func$ language plpgsql;

create or replace function inserir_transacao_debito(
    cliente_id int,
    amount int,
    description varchar(10))
returns inserir_transacao_result as $func$
declare
    cli cliente%rowtype;
    result inserir_transacao_result;
begin
    /* Se for débito, valida estouro de limit*/
    update cliente
    set current_balance = current_balance - amount
    where id = cliente_id
      and current_balance - amount + limit >= 0 
    returning *
    into cli;
   
    if not found then
        if not exists(select 1 from cliente where id = cliente_id) then
            select 1, 'Cliente inválido.', null, null into result;
            return result;
        end if;
    
        select 2, 'Saldo e limit insuficiente para executar a operação.', null, null into result;
        return result;
    end if;


    insert into transacao(cliente_id, kind, amount, submitted_at, description)
    values (cliente_id, 'd', amount, now(), description);

    select 0, null, cli.current_balance, cli.limit into result;
    return result;
end;
$func$ language plpgsql;