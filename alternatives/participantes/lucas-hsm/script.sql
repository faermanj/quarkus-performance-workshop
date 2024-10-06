CREATE TABLE clientes (
    id int,
    limit int,
    current_balance int
);

create table transactions (
    id_cliente int,
    kind char,
    description varchar(10),
    submitted_at timestamp with time zone,
    amount int
);

create index clientes_index on clientes using hash (id);
create index transactions_index on transactions using hash (id_cliente);

CREATE OR REPLACE FUNCTION update_client(client_id int, val int, kind char, description varchar(10), re timestamp with time zone)
RETURNS TABLE (
    new_limit int,
    new_current_balance int
)
LANGUAGE plpgsql AS $$
DECLARE
    ccurrent_balance int;
    climit int;
BEGIN
    BEGIN
        SELECT current_balance, limit INTO ccurrent_balance, climit FROM clientes WHERE id = client_id FOR UPDATE;

        IF (ccurrent_balance - val) < (climit * -1) THEN
            RETURN QUERY SELECT -1, -1;
            RETURN;
        END IF;

        UPDATE clientes SET current_balance = (ccurrent_balance - val) WHERE id = client_id;

        INSERT INTO transactions (id_cliente, kind, description, submitted_at, amount)
        VALUES (client_id, kind, description, re, ABS(val));
    END;
    RETURN QUERY SELECT climit, (ccurrent_balance - val);
    RETURN;
END;
$$;

CREATE TYPE Transacao AS (
       kind char,
       description varchar(10),
       amount int,
       submitted_at TIMESTAMP WITH TIME ZONE
);

CREATE OR REPLACE FUNCTION get_client_and_transactions(client_id INT)
RETURNS TABLE (
    nlimit int,
    ncurrent_balance int,
    nkind char,
    ndescription varchar(10),
    namount int,
    nsubmitted_at TIMESTAMP WITH TIME ZONE
)
AS $$
DECLARE
    ntransactions Transacao [];
    transacao record;
    c int;
BEGIN
    SELECT limit, current_balance INTO nlimit, ncurrent_balance FROM clientes WHERE id = client_id;
    SELECT COUNT(id_cliente) INTO c FROM transactions where id_cliente = client_id;
    IF c < 1 then
        RETURN QUERY SELECT nlimit, ncurrent_balance, nkind, ndescription, namount, nsubmitted_at;
        RETURN;
    END IF;
    FOR transacao IN SELECT kind, description, amount, submitted_at FROM transactions where id_cliente = client_id ORDER BY submitted_at DESC LIMIT 10 LOOP
        RETURN QUERY SELECT nlimit, ncurrent_balance, transacao.kind, transacao.description, transacao.amount, transacao.submitted_at;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  INSERT INTO clientes
  VALUES
    (1, 1000 * 100, 0),
    (2, 800 * 100, 0),
    (3, 10000 * 100, 0),
    (4, 100000 * 100, 0),
    (5, 5000 * 100, 0);
END; $$
