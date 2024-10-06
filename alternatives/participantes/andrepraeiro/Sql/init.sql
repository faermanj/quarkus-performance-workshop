CREATE  TABLE cliente (
    id integer PRIMARY KEY NOT NULL,
    current_balance integer NOT NULL,
    limit integer NOT NULL
);

CREATE  TABLE transacao (
    id SERIAL PRIMARY KEY,
    amount integer NOT NULL,
    description varchar(10) NOT NULL,
    realizadaem timestamp NOT NULL,
    idcliente integer NOT NULL
);

CREATE INDEX idx_transacao_idcliente ON transacao
(
    idcliente ASC
);

INSERT INTO cliente (id, current_balance, limit) VALUES (1, 0, -100000);
INSERT INTO cliente (id, current_balance, limit) VALUES (2, 0, -80000);
INSERT INTO cliente (id, current_balance, limit) VALUES (3, 0, -1000000);
INSERT INTO cliente (id, current_balance, limit) VALUES (4, 0, -10000000);
INSERT INTO cliente (id, current_balance, limit) VALUES (5, 0, -500000);