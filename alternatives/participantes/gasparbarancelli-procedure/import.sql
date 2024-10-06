CREATE TABLE public.CLIENTE (
                                ID SERIAL PRIMARY KEY,
                                LIMITE INT,
                                SALDO INT DEFAULT 0
) WITH (autovacuum_enabled = false);

CREATE TABLE public.TRANSACAO (
                                  ID SERIAL PRIMARY KEY,
                                  CLIENTE_ID INT NOT NULL,
                                  VALOR INT NOT NULL,
                                  TIPO CHAR(1) NOT NULL,
                                  DESCRICAO VARCHAR(10) NOT NULL,
                                  DATA TIMESTAMP NOT NULL,
                                  FOREIGN KEY (CLIENTE_ID) REFERENCES public.CLIENTE(ID)
) WITH (autovacuum_enabled = false);

INSERT INTO public.CLIENTE (ID, LIMITE)
VALUES (1, 100000),
       (2, 80000),
       (3, 1000000),
       (4, 10000000),
       (5, 500000);


CREATE OR REPLACE PROCEDURE efetuar_transacao(
    IN clienteIdParam int,
    IN kindParam varchar(1),
    IN amountParam int,
    IN descriptionParam varchar(10),
    OUT current_balanceRetorno int,
    OUT limitRetorno int
)
LANGUAGE plpgsql
AS $$
DECLARE
cliente cliente%rowtype;
    novoSaldo int;
BEGIN

    IF kindParam = 'd' THEN
        novoSaldo := amountParam * -1;
ELSE
        novoSaldo := amountParam;
END IF;

UPDATE cliente
SET current_balance = current_balance + novoSaldo
WHERE id = clienteIdParam
  AND (novoSaldo > 0 OR limit * -1 <= current_balance + novoSaldo)
    RETURNING * INTO cliente;

IF NOT FOUND THEN
            RAISE EXCEPTION 'Cliente não possui limit';
END IF;

INSERT INTO transacao (cliente_id, amount, kind, description, data)
VALUES (clienteIdParam, amountParam, kindParam, descriptionParam, current_timestamp);

SELECT cliente.current_balance, cliente.limit INTO current_balanceRetorno, limitRetorno;
END;
$$;