CREATE TABLE clientes (
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
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	CONSTRAINT fk_clientes_current_balances_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

-- INDEX
CREATE INDEX idx_clientes_id ON clientes (id);
CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);
CREATE INDEX idx_current_balances_cliente_id ON current_balances (cliente_id);

---	STORE PROCEDURE
CREATE OR REPLACE FUNCTION obter_current_balance_limit(cliente_id_param INTEGER)
RETURNS JSON AS $$
DECLARE
    resultado JSON;
BEGIN
    SELECT json_build_object('current_balance', s.amount, 'limit', c.limit)
    INTO resultado
    FROM current_balances s
    JOIN clientes c ON s.cliente_id = c.id
    WHERE s.cliente_id = cliente_id_param;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obter_balance(cliente_id_param INTEGER)
RETURNS JSON AS $$
DECLARE
    balance JSON;
BEGIN
    SELECT json_build_object(
        'current_balance', json_build_object(
            'total', (SELECT amount FROM current_balances WHERE cliente_id = cliente_id_param),
            'date_balance', NOW(),
            'limit', (SELECT limit FROM clientes WHERE id = cliente_id_param)
        ),
        'recent_transactions', COALESCE((
            SELECT json_agg(json_build_object(
                'amount', t.amount,
                'kind', t.kind,
                'description', t.description,
                'submitted_at', t.submitted_at
            ) ORDER BY t.submitted_at DESC)
            FROM transactions t
            WHERE t.cliente_id = cliente_id_param
            LIMIT 10
        ), '[]'::JSON)
    )
    INTO balance;

    RETURN balance;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION transacao(cliente_id_param INTEGER, amount_param INTEGER, kind_param CHAR(1), description_param VARCHAR(10))
RETURNS JSON AS $$
DECLARE
    current_balance_atual INTEGER;
    limit_atual INTEGER;
    novo_current_balance INTEGER;
    resultado JSON;
BEGIN
    SELECT amount INTO current_balance_atual FROM current_balances WHERE cliente_id = cliente_id_param;
    SELECT limit INTO limit_atual FROM clientes WHERE id = cliente_id_param;

    IF (amount_param > (current_balance_atual + limit_atual)) THEN
        resultado := json_build_object('limit', limit_atual, 'current_balance', current_balance_atual);
    ELSE
        INSERT INTO transactions (cliente_id, amount, kind, description)
        VALUES (cliente_id_param, amount_param, kind_param, description_param);

        novo_current_balance := current_balance_atual - amount_param;

        UPDATE current_balances SET amount = novo_current_balance WHERE cliente_id = cliente_id_param;

        SELECT json_build_object('limit', limit_atual, 'current_balance', novo_current_balance) INTO resultado;
    END IF;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reset_db()
RETURNS VOID AS $$
BEGIN
    DELETE FROM transactions;
    UPDATE current_balances SET amount = 0;
END;
$$ LANGUAGE plpgsql;

--- SEED
DO $$
BEGIN
	INSERT INTO clientes (nome, limit)
	VALUES
		('user 1', 1000 * 100),
		('user 2', 800 * 100),
		('user 3', 10000 * 100),
		('user 4', 100000 * 100),
		('user 5', 5000 * 100);
	
	INSERT INTO current_balances (cliente_id, amount)
		SELECT id, 0 FROM clientes;
END;
$$;