
create table transactions (
    cliente_id int,
    amount numeric not null,
    description varchar(10) not null,
    kind char(1) not null,
    data_hora_inclusao timestamp default NOW()
);
create table clientes (
    cliente_id int,
    nome varchar(100) not null,
    limit int not null,
    current_balance int  not null

);

create index transactions_idx_cliente_id on transactions (cliente_id);
create index transactions_idx_data_hora_inclusao on transactions (data_hora_inclusao DESC);



INSERT INTO clientes VALUES
    (1, 'Cliente 1', 100000,0),
    (2, 'Cliente 2', 80000,0),
    (3, 'Cliente 3', 1000000,0),
    (4, 'Cliente 4', 10000000,0),
    (5, 'Cliente 5', 500000,0);



create or replace procedure do_trans(
    IN p_cliente_id int,
    IN p_kind char,
    IN p_amount int,
    IN p_description text,
    out p_http_cod char(3),
    out p_current_balance int,
    out p_limit int
)
    language plpgsql
as
$$
DECLARE
    v_count int;

begin
    SELECT current_balance, limit
    into p_current_balance, p_limit
    from clientes
    where cliente_id = p_cliente_id FOR UPDATE;

    if (p_kind != 'c' AND p_kind != 'd') then
        raise exception 'Tipo inválido!';
    end if;

    if p_kind = 'c' then
        p_amount := p_amount * -1;
    end if;

    if p_kind = 'd' and p_current_balance - p_amount < (p_limit * -1) then
        p_http_cod := 422;
        raise exception using
            errcode = 'P0001',
            message = 'Sem limit!',
            hint = 'Tente um amount menor';
    end if;



    insert into transactions(cliente_id, amount, description, kind, data_hora_inclusao)
    values (p_cliente_id, abs(p_amount), p_description, p_kind,  current_timestamp);

    update clientes
    set current_balance = current_balance - p_amount
    where cliente_id = p_cliente_id
    returning current_balance, limit into p_current_balance, p_limit;


    p_http_cod := 200;

exception
    when no_data_found then
        p_http_cod := 404;
    when not_null_violation then
        p_http_cod := 422;
    when sqlstate 'P0001' then
        p_http_cod := 422;
    when others then
        p_http_cod := 422;
        raise notice 'SQL error: % - %', SQLERRM, SQLSTATE;
end;
$$;

CREATE or replace PROCEDURE  DO_EXTRATO(
    IN p_cliente_id int,
    OUT p_http_cod char(3),
    OUT p_balance text)
    language plpgsql
as
$$
DECLARE
    v_count  int := 0;
    v_result record;
BEGIN
    p_http_cod := '200';

    for v_result in SELECT  C.LIMITE AS LIMITE,
                            C.SALDO   AS SALDO,
                           VALOR,
                           DESCRICAO,
                           TIPO,
                           DATA_HORA_INCLUSAO
                    FROM clientes C
                             LEFT JOIN transactions T ON T.CLIENTE_ID = C.CLIENTE_ID
                    WHERE C.CLIENTE_ID = p_cliente_id
                    ORDER BY T.DATA_HORA_INCLUSAO DESC
                    LIMIT 10
        loop

            if v_count = 0 then
                p_balance := '{"current_balance": {
                "total": ' || v_result.SALDO || ',
                "date_balance": "' || current_timestamp || '",
                "limit": ' || v_result.LIMITE || '
              },"recent_transactions": [';
            end if;
            if v_result.amount is not null then
                p_balance := p_balance || ' {
                  "amount": ' || v_result.amount || ',
                  "kind": "' || v_result.kind || '",
                  "description": "' || v_result.description || '",
                  "submitted_at": "' || v_result.data_hora_inclusao || '"
                },';
                v_count := v_count + 1;
            end if;


        end loop;
    if (v_count > 0) then
        p_balance := trim(p_balance, ',');
    end if;
    p_balance := p_balance || ']}';
    IF(p_balance IS NULL) THEN
         raise exception no_data_found;
    end if;
exception
    when no_data_found then
        p_http_cod := 404;
    when not_null_violation then
        p_http_cod := 422;
    when sqlstate 'P0002' then
        p_http_cod := 422;
    when others then
        p_http_cod := 500;
        raise notice 'SQL error: % - %', SQLERRM, SQLSTATE;
END
$$