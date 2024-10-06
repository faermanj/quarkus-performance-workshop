CREATE UNLOGGED TABLE cliente (
    "id" INT,
	"nome" VARCHAR(100) NOT NULL,
    "limit" INT NOT NULL,
    "current_balance" INT NOT NULL,
    PRIMARY KEY(id)
);

CREATE UNLOGGED TABLE transacao (
    "id" INT GENERATED ALWAYS AS IDENTITY,
    "idCliente" INT NOT NULL,
    "amount" INT NOT NULL,
    "kind" CHAR(1) NOT NULL,
    "description" text NOT NULL,
    data TIMESTAMP NOT NULL,
    PRIMARY KEY("id"),
    CONSTRAINT fk_cliente
        FOREIGN KEY ("idCliente")
            REFERENCES cliente(id)
            ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION realizar_transacao (
    p_idCliente INT,
    p_amount INT,
    p_kind CHAR(1),
    p_description VARCHAR(10)
) RETURNS TABLE (limit_cliente INT, novo_current_balance INT) AS $$
DECLARE
    v_current_balance INT;
    v_limit INT;
BEGIN
    SELECT current_balance, limit INTO v_current_balance, v_limit 
    FROM cliente 
    WHERE id = p_idCliente FOR UPDATE;

    IF p_kind = 'd' THEN
   		IF v_current_balance - p_amount < (v_limit * -1) then
   			raise exception 'RN02:Limite insuficiente pra transacao';
   		END IF;
    END IF;
    
    IF p_kind = 'd' THEN
        UPDATE cliente SET current_balance = current_balance - p_amount WHERE id = p_idCliente;
    ELSIF p_kind = 'c' THEN
        UPDATE cliente SET current_balance = current_balance + p_amount WHERE id = p_idCliente;
    END IF;

    INSERT INTO transacao (amount, kind, description, "idCliente", data)
    VALUES
        (p_amount, p_kind, p_description, p_idCliente, CURRENT_TIMESTAMP);

    RETURN QUERY SELECT current_balance, limit FROM cliente WHERE id = p_idCliente;
END;
$$ LANGUAGE plpgsql;

INSERT INTO cliente (id, nome, limit, current_balance) VALUES
(1, 'Fulano', 100000, 0),
(2, 'Ciclano', 80000, 0),
(3, 'Beltrano', 1000000, 0),
(4, 'Betina', 10000000, 0),
(5, 'Firmina', 500000, 0);
