BEGIN;
CREATE TABLE cliente (
    current_balance INTEGER NOT NULL, 
    limit INTEGER NOT NULL, 
    id SERIAL NOT NULL, 
    PRIMARY KEY (id)
);

CREATE TYPE kindtransacao AS ENUM ('c', 'd');

CREATE TABLE transacao (
    amount INTEGER NOT NULL, 
    kind kindtransacao NOT NULL, 
    description VARCHAR(10) NOT NULL, 
    id SERIAL NOT NULL, 
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    cliente_id INTEGER NOT NULL, 
    PRIMARY KEY (id), 
    FOREIGN KEY(cliente_id) REFERENCES cliente (id)
);

ALTER TABLE transacao ADD CONSTRAINT "transacao_cliente_id_fk" FOREIGN KEY (cliente_id) REFERENCES cliente (id);
CREATE INDEX "transacao_cliente_id_id_idx" ON transacao (cliente_id, "id");

INSERT INTO cliente (id, current_balance, limit)
VALUES
    (1, 0, 100000),
    (2, 0, 80000),
    (3, 0, 1000000),
    (4, 0, 10000000),
    (5, 0, 500000);

COMMIT;



