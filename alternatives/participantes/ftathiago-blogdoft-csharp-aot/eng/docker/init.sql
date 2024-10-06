ALTER SYSTEM SET max_connections TO '300';

CREATE UNLOGGED TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance_atual integer not null default 0,
    versao integer not null default 0
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    versao integer not null,
    CONSTRAINT fk_clientes_transactions_id
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE UNIQUE INDEX uk_clientes_transactions_versao ON transactions (cliente_id,versao);

DO $$
BEGIN
    INSERT INTO clientes (nome, limit)
    VALUES
        ('o barato sai caro', 1000 * 100),
        ('zan corp ltda', 800 * 100),
        ('les cruders', 10000 * 100),
        ('padaria joia de cocaia', 100000 * 100),
        ('kid mais', 5000 * 100);    

END;
$$;

CREATE or replace FUNCTION efetuar_transacao(
    in in_description varchar(10), 
    in in_amount int, 
    in in_kind char(1),
    in in_client_id int,
    out out_operation_status int,
    out out_current_balance_atual int,
    out out_limit int) 
AS $$
declare versao_antiga int;
        novo_current_balance int;
        atualizados int;
begin
/*
*   Operation status
*   1= Sucesso
*   2= Saldo Insuficiente
*   3= Conflito
*/    
    -- Resgata current_balance atual
    select current_balance_atual 
         , versao 
         , limit
    from clientes
    where id = in_client_id
    into out_current_balance_atual, 
         versao_antiga, 
         out_limit;     

    -- Atualiza current_balance do cliente
    novo_current_balance := out_current_balance_atual - in_amount;
    if in_kind = 'c' then
        novo_current_balance := out_current_balance_atual + in_amount;
    end if;
    
    if (out_limit * -1) > novo_current_balance then
        out_operation_status := 2;
        return;  
    end if;

    update clientes set 
          current_balance_atual = novo_current_balance
        , versao = versao_antiga + 1
    where id = in_client_id
      and versao = versao_antiga;

    -- Confirma sucesso da atualização de current_balance
    GET DIAGNOSTICS atualizados = ROW_COUNT;   
    if atualizados = 0 then
        out_operation_status := 3; 
        return;
    end if;
     
    -- Registra transação 
    INSERT INTO transactions (
          cliente_id
        , amount
        , kind
        , description
        , submitted_at
        , versao
    ) VALUES(
          in_client_id
        , in_amount
        , in_kind
        , in_description
        , now()
        , versao_antiga + 1
    );

    out_current_balance_atual := novo_current_balance;     
    out_operation_status := 1;    
END;
$$ LANGUAGE plpgsql;
