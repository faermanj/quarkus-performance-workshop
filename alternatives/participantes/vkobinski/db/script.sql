DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS current_balance;
DROP TABLE IF EXISTS transacao;

CREATE TABLE cliente (
    cliente_id SERIAL PRIMARY KEY

);

CREATE TABLE current_balance (
    current_balance_id SERIAL PRIMARY KEY,
    cliente_id SERIAL,
    total INT NOT NULL,
    limit INT NOT NULL,
    CONSTRAINT fk_cliente
        FOREIGN KEY(cliente_id)
            REFERENCES cliente(cliente_id)
);

CREATE TABLE transacao (
    transacao_id SERIAL PRIMARY KEY,
    cliente_id SERIAL,
    amount INT NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_transacao_cliente
        FOREIGN KEY(cliente_id)
            REFERENCES cliente(cliente_id)
);

CREATE INDEX idx_transactions ON transacao (cliente_id ASC);
CREATE INDEX idx_current_balance ON current_balance (cliente_id ASC);

CREATE OR REPLACE FUNCTION get_cliente_details(cliente_id_param INT)
RETURNS JSONB AS $$
DECLARE
    current_balance_record RECORD;
    transactions_array JSONB;
BEGIN

    SELECT INTO current_balance_record * FROM current_balance WHERE cliente_id = cliente_id_param LIMIT 1;

     IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    transactions_array = (
        SELECT json_agg(row_to_json(trans))
        FROM (
            SELECT *
            FROM transacao
            WHERE cliente_id = cliente_id_param
            ORDER BY submitted_at DESC
            LIMIT 10
        ) trans
    );

    RETURN jsonb_build_object(
        'cliente_id', cliente_id_param,
        'current_balance', jsonb_build_object(
            'current_balance_id', current_balance_record.current_balance_id,
            'total', current_balance_record.total,
            'limit', current_balance_record.limit,
            'date_balance', now()
        ),
        'recent_transactions', transactions_array
    );

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_transaction(cliente_id_param INT, amount_param INT, kind_param VARCHAR(1), description_param VARCHAR(10), total_param INT, current_balance_id_param INT)
RETURNS INT AS $$
DECLARE
    transacao_record RECORD;
    current_balance_record RECORD;
    result INT;
BEGIN

    INSERT INTO transacao (cliente_id, amount, kind, description, submitted_at)
    VALUES (cliente_id_param, amount_param, kind_param, description_param, NOW());

    UPDATE INTO result current_balance SET total = total_param WHERE current_balance_id = current_balance_id_param RETURNING current_balance_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_transaction(cliente_id_param INT,
                                           amount_param INT,
                                           kind_param VARCHAR(1),
                                           description_param VARCHAR(10))
RETURNS JSONB AS $$
DECLARE
    transacao_record RECORD;
    current_balance_record RECORD;
    novo_total INT;
BEGIN

    SELECT INTO current_balance_record * FROM current_balance WHERE cliente_id = cliente_id_param LIMIT 1 FOR UPDATE;

    IF kind_param = 'c' THEN
      novo_total := current_balance_record.total + amount_param;
    ELSIF kind_param = 'd' THEN
        IF (current_balance_record.total - amount_param) < -current_balance_record.limit THEN
            RETURN jsonb_build_object(
                'code', 500,
                'reason', 'not_enough_funds'
            );
        END IF;
        novo_total := current_balance_record.total - amount_param;
    END IF;

    INSERT INTO transacao (cliente_id, amount, kind, description, submitted_at)
    VALUES (cliente_id_param, amount_param, kind_param, description_param, NOW());

    UPDATE current_balance SET total = novo_total WHERE cliente_id = cliente_id_param RETURNING * INTO current_balance_record;

    RETURN jsonb_build_object(
        'total', novo_total,
        'limit', current_balance_record.limit
    );
END;
$$ LANGUAGE plpgsql;




DO $$
BEGIN
  INSERT INTO cliente (cliente_id)
  VALUES
    (1),
    (2),
    (3),
    (4),
    (5);
END; $$;

DO $$
BEGIN
  INSERT INTO current_balance (cliente_id, limit, total)
  VALUES
    (1, 100000, 0),
    (2, 80000, 0),
    (3, 1000000, 0),
    (4, 10000000, 0),
    (5, 500000, 0);
END; $$
