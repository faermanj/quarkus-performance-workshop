create unlogged table clientes(
	id int primary key,
	limite bigint not null,
	saldo bigint not null default 0
);

-- default clients
insert into clientes (id, limite) values
	(1, 100000),
	(2, 80000),
	(3, 1000000),
	(4, 10000000),
	(5, 500000);

-- partioned
create unlogged table transactions(
	id bigserial not null,
	cliente int not null,
	tipo boolean not null,
	valor int not null,
	descricao varchar(10) not null,
	realizada_em timestamp not null,
	constraint fk_transactions_clientes foreign key (cliente) references clientes (id) 
)
partition by list (cliente);

-- partition per client
create table transactions_1 partition of transactions for values in (1);
create table transactions_2 partition of transactions for values in (2);
create table transactions_3 partition of transactions for values in (3);
create table transactions_4 partition of transactions for values in (4);
create table transactions_5 partition of transactions for values in (5);
create table transactions_default partition of transactions default;

-- indexes
create index on transactions (id);
create index on transactions (cliente);
create index on transactions (realizada_em desc);

-- insert transaction
create or replace procedure transar(cliente_in int, tipo_in boolean, valor_in int, descricao_in varchar(10))
language plpgsql as 
$$
begin
	-- record transaction
   	insert into transactions(cliente, tipo, valor, descricao, realizada_em)
    values (cliente_in, tipo_in, valor_in, descricao_in, now());
end
$$;

-- update saldo
create or replace procedure saldar(cliente_in int, saldo_in int)
language plpgsql as 
$$
begin
	-- record saldo
	update clientes set saldo = saldo_in where id = cliente_in;
end
$$;

-- get balance
create or replace function balance(cliente_in int) returns table(valor int, tipo bool, descricao varchar(10), realizada_em timestamp)
language plpgsql as
$$
begin
	return query select t.valor, t.tipo, t.descricao, t.realizada_em from transactions as t where t.cliente = cliente_in order by t.realizada_em desc limit 10;
end
$$
