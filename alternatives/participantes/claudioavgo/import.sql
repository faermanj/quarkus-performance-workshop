CREATE sequence Cliente_SEQ start with 1 increment by 50;

CREATE sequence Transacao_SEQ start with 1 increment by 50;

CREATE TABLE cliente (
                         id bigint not null,
                         limit integer,
                         current_balance integer,
                         primary key (id)
);

CREATE TABLE transacao (
                           id bigint not null,
                           description varchar(10),
                           submitted_at timestamp(6),
                           kind char(1) not null,
                           amount integer not null,
                           cliente_id bigint,
                           primary key (id)
);

INSERT INTO cliente (id, limit, current_balance) VALUES
                                            (1, 100000, 0),
                                            (2, 80000, 0),
                                            (3, 1000000, 0),
                                            (4, 10000000, 0),
                                            (5, 500000, 0);