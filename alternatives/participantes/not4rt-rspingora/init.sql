DROP SCHEMA IF EXISTS backend CASCADE;
DROP PROCEDURE IF EXISTS INSERIR_TRANSACAO_D CASCADE;
DROP PROCEDURE IF EXISTS INSERIR_TRANSACAO_C CASCADE;

CREATE SCHEMA backend;

CREATE UNLOGGED TABLE backend.members (
	id      SERIAL PRIMARY KEY,
	nome    VARCHAR(200) NOT NULL,
	limit  INTEGER NOT NULL,
    current_balance   INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_membercurrent_balance ON backend.members (id, current_balance);

CREATE UNLOGGED TABLE backend.transactions (
	id      SERIAL PRIMARY KEY,
    cliente_id SERIAL REFERENCES backend.members(id),
	amount  INTEGER NOT NULL,
	kind   VARCHAR(1) NOT NULL,
	description   VARCHAR(10) NOT NULL,
	current_balance_rmsc INTEGER NOT NULL,
	submitted_at   VARCHAR(200) NOT NULL
);

CREATE INDEX idx_balance ON backend.transactions (id desc, cliente_id);

INSERT INTO backend.members (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);


CREATE PROCEDURE INSERIR_TRANSACAO_D(
	p_id_cliente INTEGER,
	p_amount INTEGER,
	p_description VARCHAR(10),
	p_submitted_at VARCHAR(200),
	INOUT pout_current_balance INTEGER DEFAULT NULL,
	INOUT pout_limit INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
  WITH
	UPDATE_members AS (
		UPDATE backend.members
		SET current_balance = current_balance - p_amount
		WHERE id = p_id_cliente AND current_balance - p_amount >= -limit
		RETURNING current_balance, limit
	),
	INSERT_TRANSACAO AS (
		INSERT INTO backend.transactions (cliente_id, amount, kind, description, current_balance_rmsc, submitted_at)
		SELECT p_id_cliente, p_amount, 'd', p_description, current_balance, p_submitted_at
		from UPDATE_members
	)
	SELECT current_balance, limit
	INTO pout_current_balance, pout_limit
	FROM UPDATE_members;
END;
$$;

CREATE PROCEDURE INSERIR_TRANSACAO_C(
	p_id_cliente INTEGER,
	p_amount INTEGER,
	p_description VARCHAR(10),
	p_submitted_at VARCHAR(200),
	INOUT pout_current_balance INTEGER DEFAULT NULL,
	INOUT pout_limit INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
  WITH
	UPDATE_members AS (
		UPDATE backend.members
		SET current_balance = current_balance + p_amount
		WHERE id = p_id_cliente
		RETURNING current_balance, limit
	),
	INSERT_TRANSACAO AS (
		INSERT INTO backend.transactions (cliente_id, amount, kind, description, current_balance_rmsc, submitted_at)
		SELECT p_id_cliente, p_amount, 'c', p_description, current_balance, p_submitted_at
		from UPDATE_members
	)
	
	SELECT current_balance, limit
	INTO pout_current_balance, pout_limit
	FROM UPDATE_members;
END;
$$;
