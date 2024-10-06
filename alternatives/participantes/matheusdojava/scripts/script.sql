CREATE UNLOGGED TABLE cliente
(
    id     INT PRIMARY KEY,
    limit INT NOT NULL,
    current_balance  INT NOT NULL
);

INSERT INTO cliente (id, limit, current_balance)
VALUES (1, 100000, 0),
       (2, 80000, 0),
       (3, 1000000, 0),
       (4, 10000000, 0),
       (5, 500000, 0);

CREATE UNLOGGED TABLE TRANSACAO
(
    ID           SERIAL      PRIMARY KEY,
    ID_CLIENTE   INT         NOT NULL,
    VALOR        INT         NOT NULL,
    TIPO         VARCHAR(1)  NOT NULL,
    DESCRICAO    VARCHAR(10) NOT NULL,
    REALIZADA_EM TIMESTAMP   NOT NULL
);

CREATE INDEX idx_transacao_id_cliente ON transacao (id_cliente);
CREATE INDEX idx_transacao_id_cliente_submitted_at ON transacao (id_cliente, submitted_at DESC);


CREATE OR REPLACE FUNCTION efetuar_transacao(
clienteIdParam int,
kindParam varchar(1),
amountParam int,
descriptionParam varchar(10)
)
RETURNS TABLE (current_balanceRetorno int, limitRetorno int) AS $$
DECLARE
cliente cliente%rowtype;
novoSaldo
int;
numeroLinhasAfetadas
int;
BEGIN
PERFORM
* FROM cliente where id = clienteIdParam FOR
UPDATE;
IF
kindParam = 'd' THEN
novoSaldo := amountParam * -1;
ELSE
novoSaldo := amountParam;
END IF;

UPDATE cliente
SET current_balance = current_balance + novoSaldo
WHERE id = clienteIdParam
  AND (novoSaldo > 0 OR limit * -1 <= current_balance + novoSaldo) RETURNING *
INTO cliente;

GET DIAGNOSTICS numeroLinhasAfetadas = ROW_COUNT;

IF
numeroLinhasAfetadas = 0 THEN
RAISE EXCEPTION 'Cliente nao possui limit';
END IF;

INSERT INTO transacao (id_cliente, amount, kind, description, submitted_at)
VALUES (clienteIdParam, amountParam, kindParam, descriptionParam, current_timestamp);


RETURN QUERY SELECT cliente.current_balance, cliente.limit;
END;
$$
LANGUAGE plpgsql;