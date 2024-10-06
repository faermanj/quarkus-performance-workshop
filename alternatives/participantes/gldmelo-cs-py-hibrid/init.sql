CREATE TABLE clientes (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL DEFAULT 0,
	CONSTRAINT valida_current_balance CHECK (current_balance >= (- limit))
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
	--CONSTRAINT fk_clientes_transactions_id FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('Fulano', 1000 * 100),
		('Beltrano', 800 * 100),
		('Cicrano', 10000 * 100),
		('Deutrano', 100000 * 100),
		('Eutrano', 5000 * 100);
END;
$$;

CREATE OR REPLACE FUNCTION inserir_transacao_credito_e_retornar_current_balance (
	clienteid_in int,
	amount_in int,
	description_in varchar(10)
)
RETURNS int
AS $$
	DECLARE current_balance_atualizado int;
BEGIN	
	INSERT INTO "transactions" ("cliente_id", "amount", "kind", "description") values (clienteid_in, amount_in, 'c', description_in);
	UPDATE "clientes" set "current_balance" = "current_balance" + amount_in where "id" = clienteid_in RETURNING "current_balance" into current_balance_atualizado;
    return current_balance_atualizado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION inserir_transacao_debito_e_retornar_current_balance (
	clienteid_in int,
	amount_in int,
	description_in varchar(10)
)
RETURNS int
AS $$
	DECLARE current_balance_atualizado int;
BEGIN	
    UPDATE "clientes" set "current_balance" = "current_balance" - amount_in where "id" = clienteid_in and "current_balance" - amount_in >= ("limit" * -1) returning "current_balance" into current_balance_atualizado;

    IF current_balance_atualizado IS NOT NULL THEN
	    INSERT INTO "transactions" ("cliente_id", "amount", "kind", "description") values (clienteid_in, amount_in, 'd', description_in);
    END IF;

    RETURN current_balance_atualizado;
END;
$$ LANGUAGE plpgsql;

CREATE INDEX idx_transactions_on_cliente_id_realizado_em ON transactions USING btree (cliente_id, submitted_at);
