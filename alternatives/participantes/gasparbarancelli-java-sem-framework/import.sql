CREATE UNLOGGED TABLE public.CLIENTE (
                                ID SERIAL PRIMARY KEY,
                                LIMITE INT,
                                SALDO INT DEFAULT 0
) WITH (autovacuum_enabled = false);

CREATE UNLOGGED TABLE public.TRANSACAO (
                                  ID SERIAL PRIMARY KEY,
                                  CLIENTE_ID INT NOT NULL,
                                  VALOR INT NOT NULL,
                                  TIPO CHAR(1) NOT NULL,
                                  DESCRICAO VARCHAR(10) NOT NULL,
                                  DATA TIMESTAMP NOT NULL
) WITH (autovacuum_enabled = false);

CREATE INDEX IDX_TRANSACAO_CLIENTE ON TRANSACAO (CLIENTE_ID ASC);

INSERT INTO public.CLIENTE (ID, LIMITE)
VALUES (1, 100000),
       (2, 80000),
       (3, 1000000),
       (4, 10000000),
       (5, 500000);


CREATE OR REPLACE FUNCTION efetuar_transacao(
    clienteIdParam int,
    kindParam varchar(1),
    amountParam int,
    descriptionParam varchar(10)
)
RETURNS TABLE (current_balanceRetorno int, limitRetorno int) AS $$
DECLARE
    cliente cliente%rowtype;
    novoSaldo int;
    numeroLinhasAfetadas int;
BEGIN

    IF kindParam = 'd' THEN
            novoSaldo := amountParam * -1;
    ELSE
            novoSaldo := amountParam;
    END IF;

    UPDATE cliente SET current_balance = current_balance + novoSaldo
    WHERE id = clienteIdParam AND (novoSaldo > 0 OR limit * -1 <= current_balance + novoSaldo)
        RETURNING * INTO cliente;

    GET DIAGNOSTICS numeroLinhasAfetadas = ROW_COUNT;

    IF numeroLinhasAfetadas = 0 THEN
            RAISE EXCEPTION 'Cliente nao possui limit';
    END IF;

    INSERT INTO transacao (cliente_id, amount, kind, description, data)
    VALUES (clienteIdParam, amountParam, kindParam, descriptionParam, current_timestamp);


    RETURN QUERY SELECT cliente.current_balance, cliente.limit;
END;
$$ LANGUAGE plpgsql;