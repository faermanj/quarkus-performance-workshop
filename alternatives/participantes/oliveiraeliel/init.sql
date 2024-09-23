CREATE UNLOGGED TABLE members (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limite INTEGER NOT NULL,
	saldo INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transacoes (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transacoes_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
);

DO $$
BEGIN
	INSERT INTO members (nome, limite, saldo)
	VALUES
		('o barato sai caro', 1000 * 100, 0),
		('zan corp ltda', 800 * 100, 0),
		('les cruders', 10000 * 100, 0),
		('padaria joia de cocaia', 100000 * 100, 0),
		('kid mais', 5000 * 100, 0);
END;
$$;

CREATE OR REPLACE FUNCTION debitar(
	cliente_id_tx INT,
	valor_tx INT,
	descricao_tx VARCHAR(10))
RETURNS TABLE (
	novo_saldo INT,
	limite INT,
	possui_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
	saldo_atual int;
	limite_atual int;
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);
	SELECT 
		members.limite,
		COALESCE(saldo, 0)
	INTO
		limite_atual,
		saldo_atual
	FROM members
	WHERE id = cliente_id_tx;

	IF saldo_atual - valor_tx >= limite_atual * -1 THEN
		INSERT INTO transacoes
			VALUES(DEFAULT, cliente_id_tx, valor_tx, 'd', descricao_tx, NOW());
		
		UPDATE members
		SET saldo = saldo - valor_tx
		WHERE id = cliente_id_tx;

		RETURN QUERY
			SELECT
				saldo,
				members.limite,
				FALSE,
				'ok'::VARCHAR(20)
			FROM members
			WHERE id = cliente_id_tx;
	ELSE
		RETURN QUERY
			SELECT
				saldo,
				members.limite,
				TRUE,
				'saldo insuficiente'::VARCHAR(20)
			FROM members
			WHERE id = cliente_id_tx;
	END IF;
END;
$$;

CREATE OR REPLACE FUNCTION creditar(
	cliente_id_tx INT,
	valor_tx INT,
	descricao_tx VARCHAR(10))
RETURNS TABLE (
	novo_saldo INT,
	limite INT,
	possui_erro BOOL,
	mensagem VARCHAR(20))
LANGUAGE plpgsql
AS $$
BEGIN
	PERFORM pg_advisory_xact_lock(cliente_id_tx);

	INSERT INTO transacoes
		VALUES(DEFAULT, cliente_id_tx, valor_tx, 'c', descricao_tx, NOW());

	RETURN QUERY
		UPDATE members
		SET saldo = saldo + valor_tx
		WHERE id = cliente_id_tx
		RETURNING saldo, members.limite, FALSE, 'ok'::VARCHAR(20);
END;
$$;