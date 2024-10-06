CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE UNLOGGED TABLE IF NOT EXISTS clientes
(
    id BIGSERIAL NOT NULL,
    limit BIGINT NOT NULL,
    current_balance BIGINT NOT NULL,
    CONSTRAINT pk_clientes PRIMARY KEY (id)
);
create index clientes_id_idx
    on clientes (id);

CREATE UNLOGGED TABLE transactions
(
    id BIGSERIAL NOT NULL,
    amount      BIGINT                      NOT NULL,
    kind       CHAR                        NOT NULL,
    description  VARCHAR(10)                 NOT NULL,
    realizacao TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    cliente_id BIGINT                      NOT NULL,
    CONSTRAINT pk_transactions PRIMARY KEY (id)
);
ALTER TABLE transactions
    ADD CONSTRAINT FK_transactions_ON_CLIENTE FOREIGN KEY (cliente_id) REFERENCES clientes (id);


truncate table transactions cascade;
truncate table clientes cascade;

DO
$$
    BEGIN
        INSERT INTO clientes (limit, current_balance)
        VALUES (1000 * 100, 0),
               (800 * 100, 0),
               (10000 * 100, 0),
               (100000 * 100, 0),
               (5000 * 100, 0);
    END;
$$;