CREATE TABLE cliente (
    id INT PRIMARY KEY,
    current_balance INT NOT NULL,
    limit INT NOT NULL
);

CREATE TABLE transacao (
    id SERIAL PRIMARY KEY,
    amount INT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    realizado_em TIMESTAMP NOT NULL DEFAULT NOW(),
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE INDEX idx_cliente ON cliente(id) INCLUDE (current_balance, limit);
CREATE INDEX idx_transacao_cliente ON transacao(cliente_id);

INSERT INTO cliente (Id, limit, current_balance) VALUES
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);

CREATE OR REPLACE FUNCTION criartransacao(
    IN id_cliente INT,
    IN amount INT,
    IN kind CHAR(1),
    IN description varchar(10)
) RETURNS RECORD AS $$
DECLARE
    ret RECORD;
BEGIN
    PERFORM id FROM cliente
    WHERE id = id_cliente;

    IF not found THEN
    select 1 into ret;
    RETURN ret;
    END IF;

    INSERT INTO transacao (amount, kind, description, cliente_id)
    VALUES (ABS(amount), kind, description, id_cliente);
    UPDATE cliente
    SET current_balance = current_balance + amount
    WHERE id = id_cliente AND (amount > 0 OR current_balance + amount >= -limit)
    RETURNING current_balance, limit
    INTO ret;

    IF ret.limit is NULL THEN
        select 2 into ret;
    END IF;
    
    RETURN ret;
END;
$$ LANGUAGE plpgsql;
