CREATE UNLOGGED TABLE IF NOT EXISTS "clientes" (
	"id" SERIAL NOT NULL PRIMARY KEY,
	"limit" INTEGER NOT NULL,
	"current_balance" BIGINT NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS "transactions" (
	"id" SERIAL NOT NULL PRIMARY KEY,
	"cliente_id" INTEGER NOT NULL,
	"kind" CHARACTER(1) NOT NULL,
	"amount" BIGINT NOT NULL,
	"description" VARCHAR(10) NOT NULL,
	"submitted_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT "fk_clientes_transactions_id" FOREIGN KEY ("cliente_id") REFERENCES clientes ("id")
);

CREATE INDEX "fk_transactions_cliente_id" ON "public"."transactions" ("cliente_id");


INSERT INTO
	clientes ("limit", "current_balance")
VALUES
	(1000 * 100, 0),
	(800 * 100, 0),
	(10000 * 100, 0),
	(100000 * 100, 0),
	(5000 * 100, 0);

END;

CREATE OR REPLACE FUNCTION transacao(
    _cliente_id INTEGER,
    _amount INTEGER,
    _kind CHAR,
    _description VARCHAR(10),
    OUT codigo_erro SMALLINT,
    OUT out_limit INTEGER,
	OUT out_current_balance BIGINT
)
RETURNS record AS
$$
BEGIN
        IF _kind = 'c' THEN
            UPDATE clientes 
            SET current_balance = current_balance + _amount 
            WHERE id = _cliente_id 
            RETURNING limit, current_balance INTO out_limit, out_current_balance;
            INSERT INTO transactions(cliente_id, amount, kind, description)
            VALUES (_cliente_id, _amount, _kind, _description);
            codigo_erro := 0;
            RETURN;
        ELSIF _kind = 'd' THEN
            UPDATE clientes
            SET current_balance = current_balance - _amount
            WHERE id = _cliente_id AND current_balance - _amount > -limit
            RETURNING limit, current_balance INTO out_limit, out_current_balance;
            
            IF FOUND THEN 
              INSERT INTO transactions(cliente_id, amount, kind, description)
              VALUES (_cliente_id, _amount, _kind, _description);
              codigo_erro := 0;
            ELSE 
              codigo_erro := 2;
            END IF;

            RETURN;
        ELSE
            codigo_erro := 3;
            RETURN;
        END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION balance(
    _cliente_id INTEGER
)
RETURNS table (
	cliente_limit INTEGER,
	cliente_current_balance BIGINT,
	id int,
	cliente_id INTEGER,
	kind CHARACTER,
	amount BIGINT,
	description VARCHAR(10),
	submitted_at TIMESTAMP
	) 
	AS
$$
BEGIN
		RETURN QUERY
		SELECT c.limit as "cliente_limit", c.current_balance as "cliente_current_balance", t.*
		FROM clientes as c
		LEFT JOIN transactions as t ON c.id = t.cliente_id
		WHERE c.id = _cliente_id
		ORDER BY t.submitted_at DESC
		LIMIT 10;
END;
$$
LANGUAGE plpgsql;
