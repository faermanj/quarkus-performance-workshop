CREATE TABLE clientes (
                          id SERIAL PRIMARY KEY,
                          nome VARCHAR(50) NOT NULL,
                          limit BIGINT NOT NULL,
                          current_balance BIGINT NOT NULL
);

CREATE TABLE transactions (
                            id SERIAL PRIMARY KEY,
                            cliente_id INTEGER NOT NULL,
                            amount INT8 NOT NULL,
                            kind CHAR(1) NOT NULL,
                            description VARCHAR(10) NOT NULL,
                            submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
                            CONSTRAINT fk_clientes_transactions_id
                                FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

DO $$
BEGIN
INSERT INTO clientes (nome, limit, current_balance)
VALUES
    ('o barato sai caro', 1000 * 100, 0),
    ('zan corp ltda', 800 * 100, 0),
    ('les cruders', 10000 * 100, 0),
    ('padaria joia de cocaia', 100000 * 100, 0),
    ('kid mais', 5000 * 100, 0);
END;
$$;