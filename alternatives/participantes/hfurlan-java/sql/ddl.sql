create table transactions (
    cliente_id int,
    amount int,
    description varchar(10),
    kind char(1),
    data_hora_inclusao timestamp default NOW()
);

create table clientes (
    cliente_id int not null,
    nome varchar(100) not null,
    limit int not null constraint limit_positivo check (limit >= 0),
    current_balance_inicial int not null constraint current_balance_inicial_positivo check (current_balance_inicial >= 0),
    primary key(cliente_id)
);

create unlogged table current_balances (
    cliente_id int not null,
    current_balance int not null constraint current_balance_valido check (current_balance >= (limit * -1)),
    limit int not null,
    transacao_0_amount int,
    transacao_0_kind char(1),
    transacao_0_description varchar(10),
    transacao_0_data_hora_inclusao timestamp,
    transacao_1_amount int,
    transacao_1_kind char(1),
    transacao_1_description varchar(10),
    transacao_1_data_hora_inclusao timestamp,
    transacao_2_amount int,
    transacao_2_kind char(1),
    transacao_2_description varchar(10),
    transacao_2_data_hora_inclusao timestamp,
    transacao_3_amount int,
    transacao_3_kind char(1),
    transacao_3_description varchar(10),
    transacao_3_data_hora_inclusao timestamp,
    transacao_4_amount int,
    transacao_4_kind char(1),
    transacao_4_description varchar(10),
    transacao_4_data_hora_inclusao timestamp,
    transacao_5_amount int,
    transacao_5_kind char(1),
    transacao_5_description varchar(10),
    transacao_5_data_hora_inclusao timestamp,
    transacao_6_amount int,
    transacao_6_kind char(1),
    transacao_6_description varchar(10),
    transacao_6_data_hora_inclusao timestamp,
    transacao_7_amount int,
    transacao_7_kind char(1),
    transacao_7_description varchar(10),
    transacao_7_data_hora_inclusao timestamp,
    transacao_8_amount int,
    transacao_8_kind char(1),
    transacao_8_description varchar(10),
    transacao_8_data_hora_inclusao timestamp,
    transacao_9_amount int,
    transacao_9_kind char(1),
    transacao_9_description varchar(10),
    transacao_9_data_hora_inclusao timestamp,
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

create function creditar(p_cliente_id int, p_amount int, p_description varchar(10)) RETURNS int AS $$
declare
  current_balance_atualizado int;
begin
--with novo_current_balance as (UPDATE current_balances SET current_balance = current_balance + $1 WHERE cliente_id = $2 RETURNING current_balance) insert into transactions (cliente_id, amount, description, kind, current_balance) values ($3, $4, $5, $6, (select * from novo_current_balance)) returning current_balance
  insert into transactions (cliente_id, amount, description, kind) values (p_cliente_id, p_amount, p_description, 'c');
  update current_balances set current_balance = current_balance + p_amount,
    transacao_0_amount = p_amount,
    transacao_0_kind = 'c',
    transacao_0_description = p_description,
    transacao_0_data_hora_inclusao = NOW(),
    transacao_1_amount              = transacao_0_amount,
    transacao_1_kind               = transacao_0_kind,
    transacao_1_description          = transacao_0_description,
    transacao_1_data_hora_inclusao = transacao_0_data_hora_inclusao,
    transacao_2_amount              = transacao_1_amount,
    transacao_2_kind               = transacao_1_kind,
    transacao_2_description          = transacao_1_description,
    transacao_2_data_hora_inclusao = transacao_1_data_hora_inclusao,
    transacao_3_amount              = transacao_2_amount,
    transacao_3_kind               = transacao_2_kind,
    transacao_3_description          = transacao_2_description,
    transacao_3_data_hora_inclusao = transacao_2_data_hora_inclusao,
    transacao_4_amount              = transacao_3_amount,
    transacao_4_kind               = transacao_3_kind,
    transacao_4_description          = transacao_3_description,
    transacao_4_data_hora_inclusao = transacao_3_data_hora_inclusao,
    transacao_5_amount              = transacao_4_amount,
    transacao_5_kind               = transacao_4_kind,
    transacao_5_description          = transacao_4_description,
    transacao_5_data_hora_inclusao = transacao_4_data_hora_inclusao,
    transacao_6_amount              = transacao_5_amount,
    transacao_6_kind               = transacao_5_kind,
    transacao_6_description          = transacao_5_description,
    transacao_6_data_hora_inclusao = transacao_5_data_hora_inclusao,
    transacao_7_amount              = transacao_6_amount,
    transacao_7_kind               = transacao_6_kind,
    transacao_7_description          = transacao_6_description,
    transacao_7_data_hora_inclusao = transacao_6_data_hora_inclusao,
    transacao_8_amount              = transacao_7_amount,
    transacao_8_kind               = transacao_7_kind,
    transacao_8_description          = transacao_7_description,
    transacao_8_data_hora_inclusao = transacao_7_data_hora_inclusao,
    transacao_9_amount              = transacao_8_amount,
    transacao_9_kind               = transacao_8_kind,
    transacao_9_description          = transacao_8_description,
    transacao_9_data_hora_inclusao = transacao_8_data_hora_inclusao
    where cliente_id = p_cliente_id returning current_balance into current_balance_atualizado;
    return current_balance_atualizado;
end;
$$ LANGUAGE plpgsql;

create function debitar(p_cliente_id int, p_amount int, p_description varchar(10)) RETURNS int AS $$
declare
  current_balance_atualizado int;
begin
--with novo_current_balance as (UPDATE current_balances SET current_balance = current_balance + $1 WHERE cliente_id = $2 RETURNING current_balance) insert into transactions (cliente_id, amount, description, kind, current_balance) values ($3, $4, $5, $6, (select * from novo_current_balance)) returning current_balance
  insert into transactions (cliente_id, amount, description, kind) values (p_cliente_id, p_amount, p_description, 'd');
  update current_balances set current_balance = current_balance - p_amount,
    transacao_0_amount = p_amount,
    transacao_0_kind = 'd',
    transacao_0_description = p_description,
    transacao_0_data_hora_inclusao = NOW(),
    transacao_1_amount              = transacao_0_amount,
    transacao_1_kind               = transacao_0_kind,
    transacao_1_description          = transacao_0_description,
    transacao_1_data_hora_inclusao = transacao_0_data_hora_inclusao,
    transacao_2_amount              = transacao_1_amount,
    transacao_2_kind               = transacao_1_kind,
    transacao_2_description          = transacao_1_description,
    transacao_2_data_hora_inclusao = transacao_1_data_hora_inclusao,
    transacao_3_amount              = transacao_2_amount,
    transacao_3_kind               = transacao_2_kind,
    transacao_3_description          = transacao_2_description,
    transacao_3_data_hora_inclusao = transacao_2_data_hora_inclusao,
    transacao_4_amount              = transacao_3_amount,
    transacao_4_kind               = transacao_3_kind,
    transacao_4_description          = transacao_3_description,
    transacao_4_data_hora_inclusao = transacao_3_data_hora_inclusao,
    transacao_5_amount              = transacao_4_amount,
    transacao_5_kind               = transacao_4_kind,
    transacao_5_description          = transacao_4_description,
    transacao_5_data_hora_inclusao = transacao_4_data_hora_inclusao,
    transacao_6_amount              = transacao_5_amount,
    transacao_6_kind               = transacao_5_kind,
    transacao_6_description          = transacao_5_description,
    transacao_6_data_hora_inclusao = transacao_5_data_hora_inclusao,
    transacao_7_amount              = transacao_6_amount,
    transacao_7_kind               = transacao_6_kind,
    transacao_7_description          = transacao_6_description,
    transacao_7_data_hora_inclusao = transacao_6_data_hora_inclusao,
    transacao_8_amount              = transacao_7_amount,
    transacao_8_kind               = transacao_7_kind,
    transacao_8_description          = transacao_7_description,
    transacao_8_data_hora_inclusao = transacao_7_data_hora_inclusao,
    transacao_9_amount              = transacao_8_amount,
    transacao_9_kind               = transacao_8_kind,
    transacao_9_description          = transacao_8_description,
    transacao_9_data_hora_inclusao = transacao_8_data_hora_inclusao
    where cliente_id = p_cliente_id returning current_balance into current_balance_atualizado;
    return current_balance_atualizado;
end;
$$ LANGUAGE plpgsql;
