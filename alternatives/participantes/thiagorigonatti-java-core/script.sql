CREATE UNLOGGED TABLE tb_client
(
    id     BIGSERIAL PRIMARY KEY,
    limit BIGINT NOT NULL,
    current_balance  BIGINT NOT NULL
);

CREATE UNLOGGED TABLE tb_transaction
(
    id           BIGSERIAL PRIMARY KEY,
    amount        BIGINT      NOT NULL,
    kind         "char"      NOT NULL,
    description    VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMPTZ NOT NULL,
    client_id    BIGINT      NOT NULL,
    FOREIGN KEY (client_id) REFERENCES tb_client (id)
);

INSERT INTO tb_client (limit, current_balance)
VALUES (100000, 0),
       (80000, 0),
       (1000000, 0),
       (10000000, 0),
       (500000, 0);
