DROP FUNCTION IF EXISTS obter_balance;

CREATE OR REPLACE FUNCTION obter_balance(
	IN clienteId INT
)
RETURNS TABLE (
	r_result_code VARCHAR(20),
	r_cliente_limit INT,
	r_cliente_current_balance INT,
	r_cliente_current_balance_atualizado_em TIMESTAMPTZ,
	r_tran_amount INT,
	r_tran_kind CHAR(1),
	r_tran_description VARCHAR(10),
	r_tran_submitted_at TIMESTAMPTZ,
	r_tran_count INT
)
LANGUAGE plpgsql
AS $$
BEGIN
	-- raise notice 'Id do Cliente %.', clienteId;

	IF NOT EXISTS(SELECT FROM clientes WHERE cliente_id = clienteId) THEN
		RETURN QUERY (SELECT
			'[NOT_FOUND]'::VARCHAR,
			NULL::INT,
			NULL::INT,
			NULL::TIMESTAMPTZ,
			NULL::INT,
			NULL::CHAR,
			NULL::VARCHAR,
			NULL::TIMESTAMPTZ,
			NULL::INT
		);
		RETURN;
		-- RAISE EXCEPTION '[NOT_FOUND]::Cliente não encontrado.';
	END IF;

	RETURN QUERY (
		WITH
			cte_current_balance_cliente AS (
				SELECT
					cliente_id,
					limit,
					current_balance,
					current_balance_atualizado_em
				FROM clientes
				WHERE cliente_id = clienteId
			),
			cte_balance_cliente AS (
				SELECT
					transacao_id,
					cliente_id,
					amount,
					kind,
					description,
					submitted_at
				FROM transactions
				WHERE cliente_id = clienteId
				ORDER BY realizada_Em DESC
				FETCH FIRST 10 ROWS ONLY
			)
			SELECT
				'[OK]'::VARCHAR,
				current_balance.limit,
				current_balance.current_balance,
				current_balance.current_balance_atualizado_em,
				balance.amount,
				balance.kind,
				balance.description,
				balance.submitted_at,
				(count(balance.transacao_id) OVER())::INT
			FROM cte_current_balance_cliente as current_balance
			LEFT JOIN cte_balance_cliente as balance
				ON balance.cliente_id = current_balance.cliente_id
	);
END;
$$;

--################

DROP FUNCTION IF EXISTS criar_transacao;

CREATE OR REPLACE FUNCTION criar_transacao(
	IN clienteId INT,
	IN amount INT,
	IN kind CHAR(1),
	IN description VARCHAR(10),
	IN realizadaEm TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
)
RETURNS TABLE (
	r_result_code VARCHAR(20),
	r_cliente_limit INT,
	r_cliente_current_balance INT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_current_balance_atual_cliente RECORD;
	v_amount_crebito INT;
BEGIN
	-- raise notice 'Id do Cliente %.', clienteId;

	SELECT limit, current_balance
	FROM clientes
	WHERE cliente_id = clienteId
	INTO v_current_balance_atual_cliente;

	-- raise notice 'Saldo do Cliente %.', v_current_balance_atual_cliente;

	IF v_current_balance_atual_cliente IS NULL THEN
		RETURN QUERY (SELECT
			'[NOT_FOUND]'::VARCHAR,
			NULL::INT,
			NULL::INT
		);
		RETURN;
		-- RAISE EXCEPTION '[NOT_FOUND]::Cliente não encontrado.';
	END IF;

	-- raise notice 'Novo current_balance do Cliente %.', novo_amount_current_balance;

	v_amount_crebito = CASE WHEN kind = 'c' THEN amount ELSE -amount END;

	UPDATE clientes SET
		current_balance = current_balance + v_amount_crebito,
		current_balance_atualizado_em = CURRENT_TIMESTAMP
	WHERE cliente_id = clienteId
	RETURNING limit, current_balance
	INTO v_current_balance_atual_cliente;

	-- raise notice 'Saldo atualizado do Cliente %.', v_current_balance_atual_cliente;

	IF kind = 'd' AND v_current_balance_atual_cliente.current_balance < -v_current_balance_atual_cliente.limit THEN
		RETURN QUERY (SELECT
			'[LIMIT_EXCEEDED]'::VARCHAR,
			NULL::INT,
			NULL::INT
		);
		RETURN;
		-- RAISE EXCEPTION '[LIMIT_EXCEEDED]::O novo current_balance do cliente excede o limit permitido.';
	END IF;

	INSERT INTO transactions (cliente_id, amount, kind, description, submitted_at, current_balance)
	VALUES (
	  clienteId, amount, kind, description, realizadaEm, v_current_balance_atual_cliente.current_balance
	);

	RETURN QUERY SELECT
		'[OK]'::VARCHAR,
		v_current_balance_atual_cliente.limit,
		v_current_balance_atual_cliente.current_balance;
END;
$$;
