delete from transactions;
delete from clientes;

INSERT INTO clientes (id, current_balance, limit)
VALUES 
    (1, 0, -100000),
    (2, 0, -80000),
    (3, 0, -1000000),
    (4, 0, -10000000),
    (5, 0, -500000);

CREATE OR REPLACE FUNCTION CriarTransacao(
    IN idcliente integer,
    IN kind char(1),
    IN amount integer,
    IN description varchar(10),
    OUT status integer,
    OUT current_balance_novo integer,
    OUT limit_novo integer
) AS $$
DECLARE
    cliente_record clientes%rowtype;    
  amount_com_sinal integer;
BEGIN
    SELECT * FROM clientes INTO cliente_record WHERE id = idcliente;

    IF not found THEN --cliente não encontrado
        status := -1;
        current_balance_novo := 0;
        limit_novo := 0;
        RETURN;
    END IF;
    raise notice'Criando transacao para cliente %.', idcliente;
    INSERT INTO transactions (kind, amount, description, submitted_at, idcliente)
    VALUES (kind, amount, description, CURRENT_TIMESTAMP, idcliente);

    select amount * (case when kind = 'd' then -1 else 1 end) into amount_com_sinal;    

    UPDATE clientes
    SET current_balance = current_balance + amount_com_sinal
    WHERE id = idcliente AND (amount_com_sinal > 0 OR current_balance + amount_com_sinal >= limit)
    RETURNING current_balance, -limit INTO current_balance_novo, limit_novo;
  
    IF limit_novo IS NULL THEN --sem limit
        status := -2;
        current_balance_novo := 0;
        limit_novo := 0;
        RETURN;
    END IF;
  
    status := 0;
END;$$ LANGUAGE plpgsql;
/*
select CriarTransacao(1, 'c', 1000, 'teste')
union all
select CriarTransacao(6, 'c', 1000, 'teste')
union all
select CriarTransacao(1, 'd', 10000000, 'teste');
*/