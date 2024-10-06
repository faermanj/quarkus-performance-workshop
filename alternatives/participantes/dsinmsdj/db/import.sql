CREATE UNLOGGED TABLE cliente (
	id_cliente SERIAL primary key,
    limit integer not null,
	current_balance integer not null
);

CREATE UNLOGGED TABLE transacao (
	submitted_at timestamp not null default now(),
	id_cliente integer not null references cliente (id_cliente),
	amount integer not null,
	kind char(1) not null,
	description varchar(10) not null
);

CREATE INDEX idx_realizos_em ON transacao (submitted_at);

INSERT INTO cliente (id_cliente, limit, current_balance) VALUES
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);
