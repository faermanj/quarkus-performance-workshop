CREATE TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limite INTEGER NOT NULL
);

CREATE TABLE transacoes (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transacoes_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE TABLE saldos (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	CONSTRAINT fk_members_saldos_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

DO $$
BEGIN
	INSERT INTO members (nome, limite)
	VALUES
		('o barato sai caro', 1000 * 100),
		('zan corp ltda', 800 * 100),
		('les cruders', 10000 * 100),
		('padaria joia de cocaia', 100000 * 100),
		('kid mais', 5000 * 100);
	
	INSERT INTO saldos (cliente_id, valor)
		SELECT id, 0 FROM members;
END;
$$;


--  SERÁ SE DA CERTO?
-- create or replace function atualiza_saldo() returns trigger as $$
-- declare 
-- 	saldo_ INTEGER;
-- 	limite_ INTEGER;

-- begin

-- 	SELECT valor into saldo_, limite into limite_ FROM saldos, members WHERE saldos.cliente_id = new.cliente_id and members.id = new.cliente_id FOR UPDATE;

-- 	if (new.tipo = 'c') then
-- 		update saldos set valor = saldo_ + new.valor where cliente_id = new.cliente_id;
-- 	else
-- 		update saldos set valor = saldo_ - new.valor where cliente_id = new.cliente_id;
-- 	end if;

-- 	return new.valor;
-- end;

-- $$ language plpgsql;


-- create trigger atualiza_saldo before insert on transacoes for each row execute procedure atualiza_saldo();