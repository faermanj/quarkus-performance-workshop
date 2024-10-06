
create unlogged table if not exists members (
	id serial primary key,
  	limit integer,
	current_balance integer
);

create unlogged table if not exists transactions (
	id serial primary key,
	clienteId integer not null references members(id),
	amount integer,
	kind char not null,
	description varchar(10),
	realizadaEm timestamp
);

create index if not exists idx_transactions_clienteId on transactions(clienteId);

insert into members (limit, current_balance) 
values
  (100000, 0),
  (80000, 0),
  (1000000, 0),
	(10000000, 0),
	(500000, 0);

create type meuTipo as (codigo integer, limit integer, current_balance integer);

create or replace function criarTransacao(
	in clienteId integer,
	in amount integer,
	in kind char,
	in description varchar(10)
) returns meuTipo as $$
	declare
		cliente members%rowtype;
		mt meuTipo;
		novoSaldo integer;
	begin 
		perform pg_advisory_xact_lock(clienteId);

		select * 
		into cliente
		from members
		where id = clienteId;
		
		if cliente.id is null then
			mt.codigo := -1;
			return mt;
		end if;

		if kind = 'd' then
			novoSaldo := cliente.current_balance - amount;
		else
			novoSaldo := cliente.current_balance + amount;
		end if;

		if novoSaldo + cliente.limit < 0 then
			mt.codigo := -2;
			return mt;
		end if;

		insert into transactions 
		(amount, kind, description, clienteId, realizadaEm)
		values
		(amount, kind, description, clienteId, now()::timestamp);

		update members
		set current_balance = novoSaldo
		where id = clienteId;
		
		mt.codigo := 1;
		mt.limit := cliente.limit;
		mt.current_balance := novoSaldo;
		
		return mt;
	end;
$$ language plpgsql;


create type current_balancetype as (
	total integer,
	dataExtrato timestamp,
	limit integer
);

create or replace function obterbalance(
	in idCliente integer
) returns json as $$
	declare
		cliente members%rowtype;
		current_balance current_balancetype;
		ultimastransactions json[];
	begin

		select * 
		into cliente
		from members
		where id = idCliente;

		if cliente.id is null then
			return json_build_object(
				'codigo', -1
			);
		end if;

		current_balance.total := cliente.current_balance;
		current_balance.dataExtrato := now()::timestamp;
		current_balance.limit := cliente.limit;

		select array_agg(
			json_build_object(
			'amount', t.amount,
			'kind', t.kind,
			'description', t.description,
			'realizadaEm', t.realizadaEm
		) order by t.realizadaEm desc
		)
		into ultimastransactions
		from (
			select *
			from transactions tr	
			where tr.clienteId = idCliente
			order by tr.realizadaEm desc
			limit 10 offset 0
		) as t;

    return json_build_object(
			'codigo', 1,
        'current_balance', json_build_object(
            'total', current_balance.total,
            'dataExtrato', current_balance.dataExtrato,
            'limit', current_balance.limit
        ),
        'ultimastransactions', ultimastransactions
    );
	end;
$$ language plpgsql;
