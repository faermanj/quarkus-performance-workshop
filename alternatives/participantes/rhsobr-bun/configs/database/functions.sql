CREATE
OR REPLACE FUNCTION gera_balance(cliente_id_p INTEGER) RETURNS JSON AS $$
DECLARE
    RESULT JSON;

BEGIN
    SELECT
        JSONB_BUILD_OBJECT(
            's',
            (
                SELECT
                    COALESCE(
                        JSONB_BUILD_OBJECT(
                            't',
                            cl.current_balance,
                            'l',
                            cl.limit
                        ),
                        NULL :: JSONB
                    )
                FROM
                    members cl
                WHERE
                    cl.id = cliente_id_p
                LIMIT
                    1
            ), 'ut', (
                SELECT
                    COALESCE(JSONB_AGG(line), '[]' :: JSONB)
                FROM
                    (
                        SELECT
                            JSONB_BUILD_OBJECT(
                                'v',
                                t.amount,
                                't',
                                t.kind,
                                'd',
                                t.description,
                                'r',
                                to_char (t.submitted_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
                            ) AS line
                        FROM
                            transactions AS t
                        WHERE
                            t.cliente_id = cliente_id_p
                        ORDER BY
                            t.submitted_at DESC
                        LIMIT
                            10
                    ) AS _
            )
        ) INTO RESULT;

RETURN RESULT;

END;

$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION inclui_transacao(
    cliente_id_p INTEGER,
    kind_p CHAR,
    amount_p INTEGER,
    description_p VARCHAR
) RETURNS JSON AS $$
DECLARE
    RESULT JSON;

BEGIN
    WITH insertions AS (
        INSERT INTO
            transactions (cliente_id, amount, kind, description)
        SELECT
            id,
            amount_p,
            kind_p,
            description_p
        FROM
            members cl
        WHERE
            cl.id = cliente_id_p
            AND (
                kind_p = 'c'
                OR cl.current_balance - amount_p >= cl.limit * -1
            )
        LIMIT
            1 FOR NO KEY
        UPDATE
            RETURNING cliente_id
    )
    UPDATE
        members cl
    SET
        current_balance = current_balance + (
            CASE
                WHEN kind_p = 'd' THEN amount_p * -1
                ELSE amount_p
            END
        )
    FROM
        insertions ins
    WHERE
        cl.id = ins.cliente_id RETURNING COALESCE(
            JSONB_BUILD_OBJECT('current_balance', current_balance, 'limit', limit),
            NULL :: JSONB
        ) INTO RESULT;

RETURN RESULT;

END;

$$ LANGUAGE plpgsql;