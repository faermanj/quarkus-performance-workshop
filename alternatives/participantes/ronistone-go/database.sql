CREATE UNLOGGED TABLE members (
       id SMALLSERIAL PRIMARY KEY,
       limit INTEGER,
       amount INTEGER
);

CREATE UNLOGGED TABLE transactions (
--          id SERIAL PRIMARY KEY,
--          cliente_id INTEGER NOT NULL,
--          amount INTEGER NOT NULL,
--          kind CHAR(1) NOT NULL,
--          description VARCHAR(10) NOT NULL,
--          submitted_at TIMESTAMP NOT NULL DEFAULT NOW()

         id SERIAL PRIMARY KEY,
         cliente_id SMALLINT,
         amount INTEGER,
         kind CHAR(1),
         description VARCHAR(10),
         submitted_at TIMESTAMP
--          CONSTRAINT fk_members_transactions_id
--              FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions(cliente_id, submitted_at);

INSERT INTO members (id, limit, amount)
    VALUES
        (1, 100000, 0),
        (2, 80000, 0),
        (3, 1000000, 0),
        (4, 10000000, 0),
        (5, 500000, 0);


CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');

-- create function make_transaction(transaction_client_id integer, transaction_value integer, transaction_type character, transaction_description text)
--     returns TABLE(amount integer, limit integer)
--     language plpgsql
-- as
-- $$
-- DECLARE
--     client RECORD;
-- BEGIN
--     -- Select amount and limit from members
--     SELECT INTO client members.amount, members.limit FROM members WHERE id = transaction_client_id FOR UPDATE;
--
--     -- Update client value
--     client.amount := client.amount + transaction_value;
--
--     -- Check if the new balance is less than the negative limit
--     IF client.amount < -client.limit THEN
--         RAISE EXCEPTION 'current_balance insuficiente';
--     END IF;
--
--     -- Update members
--     UPDATE members SET amount = client.amount WHERE id = transaction_client_id;
--
--     -- Insert into transactions
--     INSERT INTO transactions(amount, cliente_id, kind, description, submitted_at)
--     VALUES (transaction_value, transaction_client_id, transaction_type, transaction_description, NOW());
--
--     -- Return the updated client values
--     RETURN QUERY SELECT client.amount, client.limit;
-- END; $$;