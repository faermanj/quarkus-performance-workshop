CREATE TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	CONSTRAINT fk_members_current_balances_id
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
	
	INSERT INTO current_balances (cliente_id, amount)
		SELECT id, 0 FROM members;
END;
$$;


--  SERÁ SE DA CERTO?
-- create or replace function atualiza_current_balance() returns trigger as $$
-- declare 
-- 	current_balance_ INTEGER;
-- 	limit_ INTEGER;

-- begin

-- 	SELECT amount into current_balance_, limit into limit_ FROM current_balances, members WHERE current_balances.cliente_id = new.cliente_id and members.id = new.cliente_id FOR UPDATE;

-- 	if (new.kind = 'c') then
-- 		update current_balances set amount = current_balance_ + new.amount where cliente_id = new.cliente_id;
-- 	else
-- 		update current_balances set amount = current_balance_ - new.amount where cliente_id = new.cliente_id;
-- 	end if;

-- 	return new.amount;
-- end;

-- $$ language plpgsql;


-- create trigger atualiza_current_balance before insert on transactions for each row execute procedure atualiza_current_balance();