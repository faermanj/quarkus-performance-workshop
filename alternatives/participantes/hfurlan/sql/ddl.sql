create table transactions (
    cliente_id int not null,
    amount numeric not null,
    description varchar(10) not null,
    kind char(1) not null,
    current_balance numeric not null,
    data_hora_inclusao timestamp default NOW()
);

create index transactions_idx_cliente_id on transactions (cliente_id);

create table clientes (
    cliente_id int not null,
    nome varchar(100) not null,
    limit numeric not null constraint limit_positivo check (limit >= 0),
    current_balance_inicial numeric not null constraint current_balance_inicial_positivo check (current_balance_inicial >= 0),
    primary key(cliente_id)
);

create unlogged table current_balances (
    cliente_id int not null,
    current_balance numeric not null constraint current_balance_valido check (current_balance >= (limit * -1)),
    limit numeric not null,
    primary key(cliente_id)
);

create or replace function inserir_current_balance()
  returns TRIGGER 
  language PLPGSQL
  as
$$
begin
    insert into current_balances (cliente_id, current_balance, limit) values (NEW.cliente_id, NEW.current_balance_inicial, NEW.limit);
    return NEW;
end;
$$;

create or replace function remover_current_balance()
  returns TRIGGER 
  language PLPGSQL
  as
$$
begin
    delete from current_balances where cliente_id = OLD.cliente_id;
    return OLD;
end;
$$;

create or replace trigger clientes_inserir_current_balance
    after insert on clientes
    for each row
    execute function inserir_current_balance();

create or replace trigger clientes_remover_current_balance
    after delete ON clientes
    for each row
    execute function remover_current_balance();
