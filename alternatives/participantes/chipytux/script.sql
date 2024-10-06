CREATE UNLOGGED TABLE customer
(
    id SERIAL PRIMARY KEY,
    limit BIGINT NOT NULL,
    current_balance  BIGINT NOT NULL
);

CREATE UNLOGGED TABLE transaction
(
    id SERIAL PRIMARY KEY,
    customer_id  INT     NOT NULL,
    amount        BIGINT     NOT NULL,
    kind         CHAR(1)     NOT NULL,
    description    VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP   NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_customer_id
        FOREIGN KEY (customer_id) REFERENCES customer (id)
);


BEGIN;

INSERT INTO customer(id, limit, current_balance)
VALUES (1, 100000, 0),
       (2, 80000, 0),
       (3, 1000000, 0),
       (4, 10000000, 0),
       (5, 500000, 0);
COMMIT;
