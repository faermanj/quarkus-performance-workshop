-- Coloque scripts iniciais aqui

CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
        current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description text NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

DO $$
BEGIN
	INSERT INTO members (nome, limit)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);

END;
$$;

-- criando indices
CREATE INDEX indice_transactions_1 ON transactions (cliente_id, submitted_at DESC) WHERE cliente_id = 1;
CREATE INDEX indice_transactions_2 ON transactions (cliente_id, submitted_at DESC) WHERE cliente_id = 2;
CREATE INDEX indice_transactions_3 ON transactions (cliente_id, submitted_at DESC) WHERE cliente_id = 3;
CREATE INDEX indice_transactions_4 ON transactions (cliente_id, submitted_at DESC) WHERE cliente_id = 4;
CREATE INDEX indice_transactions_5 ON transactions (cliente_id, submitted_at DESC) WHERE cliente_id = 5;

-- criando gatilhos para atualizar o current_balance
CREATE OR REPLACE FUNCTION reconcile_amount_trigger_function()
RETURNS TRIGGER LANGUAGE plpgsql AS $$

DECLARE
	oldcurrent_balance INT;
	oldlimit INT;

BEGIN

	SELECT current_balance, limit INTO oldcurrent_balance, oldlimit
	FROM members c 
	WHERE id = NEW.cliente_id;

	IF NEW.kind = 'd' and new.amount > 0 THEN
		NEW.amount = NEW.amount * -1;
		IF oldcurrent_balance + NEW.amount + oldlimit < 0 THEN
			RAISE EXCEPTION 'limit excedido';
		END IF;
	END IF;

	UPDATE members SET current_balance = current_balance + NEW.amount WHERE id = NEW.cliente_id AND SALDO + NEW.VALOR + oldlimit > 0;
RETURN NEW;

END;

$$;

CREATE TRIGGER reconcile_amount_trigger
AFTER INSERT ON transactions
FOR EACH ROW
EXECUTE FUNCTION reconcile_amount_trigger_function();

