
CREATE TABLE public.clientes (
	id serial NOT NULL,
	current_balance int8 NOT NULL,
	limit int8 NOT NULL,
	CONSTRAINT clientes_pkey PRIMARY KEY (id)
);


CREATE TABLE transactions (
	id serial NOT NULL,
	id_cliente int8 NOT NULL,
	kind_transaction varchar(1) NOT NULL,
	amount int8 NOT NULL,
	description varchar(10) NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT transactions_pkey PRIMARY KEY (id)
);

ALTER TABLE public.transactions ADD CONSTRAINT transactions_id_client FOREIGN KEY (id_cliente) REFERENCES clientes(id) ON DELETE CASCADE;

CREATE INDEX transactions_id_cliente_idx ON public.transactions USING btree (id_cliente, id);

-- CREATE OR REPLACE FUNCTION get_client_transactions(client_id INT8)
-- RETURNS TABLE (
--     current_balance int8,
--     limit int8,
--     amount int8,
--     kind_transaction VARCHAR,
--     description VARCHAR,
--     created_at TIMESTAMP
-- ) AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT c.current_balance, c.limit, t.amount, t.kind_transaction, t.description, t.created_at
--     FROM clientes c
--     JOIN transactions t ON t.id_cliente = c.id
--     WHERE c.id = client_id
--     ORDER BY t.id DESC
--     LIMIT 10;
--     IF NOT FOUND THEN
--         RETURN QUERY
--         SELECT c.current_balance, c.limit,NULL::INT8, NULL::VARCHAR, NULL::VARCHAR, NULL::TIMESTAMP
--         FROM clientes c
--         WHERE c.id = client_id;
--     END IF;
-- END;
-- $$ LANGUAGE plpgsql;

INSERT INTO
    clientes (id, current_balance, limit)
VALUES
    (1, 0, 100000),
    (2, 0, 80000),
    (3, 0, 1000000),
    (4, 0, 10000000),
    (5, 0, 500000);
    
   