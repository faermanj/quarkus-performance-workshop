CREATE UNLOGGED TABLE
    "members" (
                   "id" SERIAL NOT NULL,
                   "current_balance" INTEGER NOT NULL,
                   "limit" INTEGER NOT NULL,
                   CONSTRAINT "members_pkey" PRIMARY KEY ("id")
);

CREATE UNLOGGED TABLE
    "transactions" (
                     "id" SERIAL NOT NULL,
                     "amount" INTEGER NOT NULL,
                     "id_cliente" INTEGER NOT NULL,
                     "kind" char(1) NOT NULL,
                     "description" VARCHAR(10) NOT NULL,
                     "submitted_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                     CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

CREATE OR REPLACE FUNCTION get_balance(customer_id INT)
    RETURNS JSON AS
$$
DECLARE
customer_data JSON;
    statements_data JSON;
BEGIN
SELECT json_build_object('total', current_balance, 'limit', limit, 'date_balance', now())
INTO customer_data
FROM members
WHERE id = customer_id;

SELECT COALESCE(json_agg(json_build_object('amount', amount, 'kind', kind, 'description', description, 'submitted_at', submitted_at)), '[]'::JSON)
INTO statements_data
FROM (
         SELECT amount, kind, description, submitted_at
         FROM transactions
         WHERE id_cliente = customer_id
         ORDER BY submitted_at DESC
             LIMIT 10
     ) AS t;

RETURN json_build_object(
        'current_balance', customer_data,
        'recent_transactions', statements_data
       );
END;
$$
LANGUAGE plpgsql;

CREATE INDEX transactions_ordering ON transactions (submitted_at DESC, id_cliente);

INSERT INTO
    members (current_balance, limit)
VALUES
    (0, 1000 * 100),
    (0, 800 * 100),
    (0, 10000 * 100),
    (0, 100000 * 100),
    (0, 5000 * 100);