CREATE TABLE IF NOT EXISTS members (
    id INT PRIMARY KEY,
    limit BIGINT,
    current_balance BIGINT
);

CREATE INDEX idx_members_id ON members (id);

CREATE TABLE IF NOT EXISTS transactions
(
    id SERIAL PRIMARY KEY,
    cliente_id integer,
    amount integer,
    kind character varying,
    description character varying,
    submitted_at timestamp without time zone
);

CREATE INDEX IF NOT EXISTS idx_transactions_cliente_id
    ON public.transactions USING btree
    (cliente_id ASC NULLS LAST)
    TABLESPACE pg_default;

INSERT INTO members (id, limit, current_balance)
SELECT 1, 1000 * 100, 0 WHERE NOT EXISTS (SELECT 1 FROM members WHERE id = 1);
INSERT INTO members (id, limit, current_balance)
SELECT 2, 800 * 100, 0 WHERE NOT EXISTS (SELECT 1 FROM members WHERE id = 2);
INSERT INTO members (id, limit, current_balance)
SELECT 3, 10000 * 100, 0 WHERE NOT EXISTS (SELECT 1 FROM members WHERE id = 3);
INSERT INTO members (id, limit, current_balance)
SELECT 4, 100000 * 100, 0 WHERE NOT EXISTS (SELECT 1 FROM members WHERE id = 4);
INSERT INTO members (id, limit, current_balance)
SELECT 5, 5000 * 100, 0 WHERE NOT EXISTS (SELECT 1 FROM members WHERE id = 5);