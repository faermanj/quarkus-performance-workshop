CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
	id bigint NOT NULL,
	limit bigint DEFAULT 0 NOT NULL,
	current_balance bigint DEFAULT 0 NOT NULL,
	CONSTRAINT cliente_pk PRIMARY KEY (id)
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacao (
	id bigserial NOT NULL,
	id_cliente bigint NOT NULL,
	description varchar(10) NULL,
	kind char(1) NOT NULL,
	amount bigint NOT NULL,
	submitted_at timestamp DEFAULT current_timestamp NULL,
	CONSTRAINT transacao_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS transacao_id_cliente_idx ON transacao (id_cliente);

DO $$
BEGIN
    IF NOT EXISTS (SELECT * from cliente) THEN
        INSERT INTO cliente (id, limit, current_balance)
        VALUES
            (1, 100000, 0),
            (2, 80000, 0),
            (3, 1000000, 0),
            (4, 10000000, 0),
            (5, 500000, 0);
    end if;
end; $$
