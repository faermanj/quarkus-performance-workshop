create unlogged table if not exists contas (
    id serial primary key,
    limit integer not null,
    current_balance integer not null,
    updated_at timestamptz
);

insert into contas (id, limit, current_balance)
values (1, 100000, 0), (2, 80000, 0), (3, 1000000, 0), (4, 10000000, 0), (5, 500000, 0);

create unlogged table if not exists transactions (
    id serial primary key,
    conta_id integer not null references contas(id),
    amount integer not null,
    description text not null,
    kind text check (kind in ('c', 'd')),
    submitted_at timestamp with time zone not null,
    foreign key (conta_id) references contas(id)
);

create index if not exists idx_transactions_conta_id on transactions(conta_id);

create or replace function process(
    conta_id integer,
    amount integer,
    description text,
    kind text
)
returns JSON
language plpgsql as $$
begin
    -- locking
    perform current_balance, limit from contas where id = conta_id for update;
    if kind = 'd' then
        if (select current_balance + limit from contas where id = conta_id) < amount then
            raise exception 'current_balance insuficiente' using errcode = '23000';
        else
            update contas set current_balance = current_balance - amount, updated_at = now() where id = conta_id;
            insert into transactions (conta_id, amount, description, kind, submitted_at) values (conta_id, amount, description, kind, now());
        end if;
    elsif kind = 'c' then
        update contas set current_balance = current_balance + amount, updated_at = now() where id = conta_id;
        insert into transactions (conta_id, amount, description, kind, submitted_at) values (conta_id, amount, description, kind, now());
    else
        raise exception 'kind invalido' using errcode = '23000';
    end if;
    return (select json_build_object('limit', limit, 'current_balance', current_balance) from contas where id = conta_id);
end;
$$;

