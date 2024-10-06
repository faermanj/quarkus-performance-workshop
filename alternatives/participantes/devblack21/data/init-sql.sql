DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clientes;

CREATE UNLOGGED TABLE clientes (
    id     SMALLSERIAL PRIMARY KEY,
    limit INT NOT NULL,
    current_balance  BIGINT NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
   id           SERIAL PRIMARY KEY,
   cliente_id   SMALLINT NOT NULL,
   amount        BIGINT NOT NULL,
   kind         CHAR(1) NOT NULL,
   description    TEXT NOT NULL,
   data_hora TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()::timestamp,
   CONSTRAINT fk_transacao_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id)
);

CREATE INDEX ON transactions (cliente_id, data_hora DESC);
CREATE UNIQUE INDEX ON clientes (id);


INSERT INTO clientes(id, limit, current_balance) VALUES 
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);


CREATE OR REPLACE FUNCTION public.envio_transacao(
    id_cliente INT,
    description TEXT,
    kind TEXT,
    amount BIGINT
) RETURNS JSON AS
$$
DECLARE
    current_balanceAtual BIGINT;
    novoSaldo BIGINT;
    id_c INT;
    l INT;
BEGIN
    SELECT id INTO id_c FROM clientes WHERE id = id_cliente;
    SELECT current_balance INTO current_balanceAtual FROM clientes WHERE id = id_cliente FOR UPDATE;
    SELECT limit INTO l FROM clientes WHERE id = id_cliente;

    IF id_c ISNULL THEN
        RETURN id_c;
    END IF;

    IF kind = 'c' THEN
        novoSaldo := current_balanceAtual + amount;
    ELSE
        novoSaldo := current_balanceAtual - amount;
    END IF;
   
    IF novoSaldo >= -l THEN
        UPDATE clientes SET current_balance = novoSaldo WHERE id = id_cliente;
        INSERT INTO transactions(cliente_id, amount, kind, description) VALUES (id_cliente, amount, kind, description);
        RETURN json_build_object('id', id_cliente, 'limit', l, 'current_balance', novoSaldo);
    ELSE
        RAISE EXCEPTION 'O cliente não tem limit para executar essa transação.'; 
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.get_transactions(
    id_cliente INT
) RETURNS JSON AS
$$
DECLARE
	cliente JSON;
	transactions JSON;
BEGIN	
	SELECT to_jsonb(c) INTO cliente FROM clientes as c WHERE c.id = id_cliente FOR UPDATE;
   
    IF cliente ISNULL THEN
	  RAISE EXCEPTION 'Não existe um cliente com o id informado'; 
    ELSE
		SELECT jsonb_agg(to_jsonb(transactions_by_user)) INTO transactions
		FROM (
				SELECT * FROM transactions AS t
			  	WHERE t.cliente_id = id_cliente
			  	ORDER BY t.data_hora DESC
			    LIMIT 10 FOR UPDATE
			 ) AS transactions_by_user;
		
		RETURN json_build_object('current_balance', cliente, 'transactions', transactions);
    END IF;
END;
$$ LANGUAGE plpgsql;