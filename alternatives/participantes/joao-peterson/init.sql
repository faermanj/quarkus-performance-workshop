create unlogged table clientes(
	id int primary key,
	limit bigint not null,
	current_balance bigint not null default 0
);

-- default clients
insert into clientes (id, limit) values
	(1, 100000),
	(2, 80000),
	(3, 1000000),
	(4, 10000000),
	(5, 500000);

-- partioned
create unlogged table transactions(
	id bigserial not null,
	cliente int not null,
	kind boolean not null,
	amount int not null,
	description varchar(10) not null,
	submitted_at timestamp not null,
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
create index on transactions (submitted_at desc);

-- insert transaction
create or replace procedure transar(cliente_in int, kind_in boolean, amount_in int, description_in varchar(10))
language plpgsql as 
$$
begin
	-- record transaction
   	insert into transactions(cliente, kind, amount, description, submitted_at)
    values (cliente_in, kind_in, amount_in, description_in, now());
end
$$;

-- update current_balance
create or replace procedure saldar(cliente_in int, current_balance_in int)
language plpgsql as 
$$
begin
	-- record current_balance
	update clientes set current_balance = current_balance_in where id = cliente_in;
end
$$;

-- get balance
create or replace function balance(cliente_in int) returns table(amount int, kind bool, description varchar(10), submitted_at timestamp)
language plpgsql as
$$
begin
	return query select t.amount, t.kind, t.description, t.submitted_at from transactions as t where t.cliente = cliente_in order by t.submitted_at desc limit 10;
end
$$
