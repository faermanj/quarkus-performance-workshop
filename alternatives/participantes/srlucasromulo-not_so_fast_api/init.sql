\c rinha;


CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);


CREATE TABLE transacao (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES cliente(id),
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP DEFAULT NOW()
);


CREATE OR REPLACE PROCEDURE init_db() AS $$
BEGIN
    INSERT INTO cliente(limit)
        VALUES
            (100000),
            (80000),
            (1000000),
            (10000000),
            (500000)
    ;
END;
$$ LANGUAGE plpgsql;

CALL init_db();


CREATE OR REPLACE PROCEDURE reset_db() AS $$
BEGIN
    TRUNCATE TABLE cliente RESTART IDENTITY CASCADE;
    CALL init_db();
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION creditar(_cliente_id INT, _amount INT, _description VARCHAR(10)) RETURNS JSONB AS $$
DECLARE
    record RECORD;
BEGIN
    PERFORM current_balance FROM cliente WHERE id = _cliente_id LIMIT 1 FOR NO KEY UPDATE;

    IF NOT FOUND THEN
        RAISE SQLSTATE '22000';     -- cliente not found
    END IF;

    UPDATE cliente SET current_balance = current_balance + _amount WHERE id = _cliente_id
        RETURNING limit, current_balance INTO record;
    INSERT INTO transacao (cliente_id, amount, kind, description) VALUES (_cliente_id, _amount, 'c', _description);

    RETURN jsonb_build_object('limit', record.limit, 'current_balance', record.current_balance);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION debitar(_cliente_id INT, _amount INT, _description VARCHAR(10)) RETURNS JSONB AS $$
DECLARE
    record RECORD;
    current_balance_atual int;
    limit_cliente int;
BEGIN
    SELECT limit, current_balance INTO limit_cliente, current_balance_atual FROM cliente WHERE id = _cliente_id LIMIT 1 FOR NO KEY UPDATE;

    IF NOT FOUND THEN
        RAISE SQLSTATE '22000';     -- cliente not found
    END IF;

    IF current_balance_atual - _amount >= limit_cliente * -1 THEN
        UPDATE cliente SET current_balance = current_balance - _amount WHERE id = _cliente_id
            RETURNING limit, current_balance INTO record;
        INSERT INTO transacao (cliente_id, amount, kind, description) VALUES (_cliente_id, _amount, 'd', _description);
    ELSE
        RAISE SQLSTATE '23000';     -- limit excedido
    END IF;

    RETURN jsonb_build_object('limit', record.limit, 'current_balance', record.current_balance);
END;
$$ LANGUAGE plpgsql;
