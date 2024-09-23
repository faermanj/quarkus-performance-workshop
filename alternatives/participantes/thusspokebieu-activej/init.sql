CREATE UNLOGGED TABLE IF NOT EXISTS members (
	id SERIAL PRIMARY KEY,
	limite INTEGER NOT NULL,
  saldo INTEGER NOT NULL 
);

CREATE INDEX IF NOT EXISTS idx_members ON members USING btree(id);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_members_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES members(id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_transactions_cliente_id ON transactions USING btree(cliente_id);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM members) THEN
        INSERT INTO members (limite, saldo)
        VALUES
            (1000 * 100, 0),
            (800 * 100, 0),
            (10000 * 100, 0),
            (100000 * 100, 0),
            (5000 * 100, 0);
    END IF;
END;
$$;



CREATE OR REPLACE FUNCTION extrato(_cliente_id INTEGER)
RETURNS JSON AS $$
DECLARE
    saldo JSON;
    ultimas_transactions JSON;
BEGIN
    SELECT
        json_build_object(
            'total', c.saldo,
            'data_extrato', NOW(),
            'limite', c.limite
        )
    INTO
        saldo
    FROM
        members c
    WHERE
        c.id = _cliente_id;

    IF NOT FOUND THEN 
      RETURN NULL;
    END IF;

    SELECT
        CASE
            WHEN COUNT(*) > 0 THEN json_agg(json_build_object(
                'valor', t.valor,
                'tipo', t.tipo,
                'descricao', t.descricao,
                'realizada_em', t.realizada_em
            ))
            ELSE '[]'::JSON
        END
    INTO
        ultimas_transactions
    FROM (
        SELECT
            valor,
            tipo,
            descricao,
            realizada_em
        FROM
            transactions
        WHERE
            cliente_id = _cliente_id
        ORDER BY
            id DESC
        LIMIT 10
    ) t;

    RETURN json_build_object(
        'saldo', saldo,
        'ultimas_transactions', ultimas_transactions
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION transacao(
    _cliente_id INTEGER,
    _valor INTEGER,
    _tipo CHAR,
    _descricao VARCHAR(10),
    OUT status SMALLINT,
    OUT resultado JSON
)
RETURNS record AS
$$
BEGIN
        IF _tipo = 'c' THEN
            UPDATE members 
            SET saldo = saldo + _valor 
            WHERE id = _cliente_id 
            RETURNING json_build_object('limite', limite, 'saldo', saldo) INTO resultado;
            INSERT INTO transactions(cliente_id, valor, tipo, descricao)
            VALUES (_cliente_id, _valor, _tipo, _descricao);
            status := 200;
        ELSIF _tipo = 'd' THEN
            UPDATE members
            SET saldo = saldo - _valor
            WHERE id = _cliente_id AND saldo - _valor > -limite
            RETURNING json_build_object('limite', limite, 'saldo', saldo) INTO resultado;
            
            IF FOUND THEN 
              INSERT INTO transactions(cliente_id, valor, tipo, descricao)
              VALUES (_cliente_id, _valor, _tipo, _descricao);
              status := 200;
            ELSE 
              status := 422;
              resultado := '';
            END IF;
        ELSE
            status := 422;
            resultado := '';
        END IF;
END;
$$
LANGUAGE plpgsql;

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
SELECT pg_prewarm('transactions');
SELECT pg_prewarm('idx_members');
SELECT pg_prewarm('idx_transactions_cliente_id');
