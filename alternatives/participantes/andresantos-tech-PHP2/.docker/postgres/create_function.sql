CREATE OR REPLACE FUNCTION createtransaction(
    IN account_id integer,
    IN amount integer,
    IN kind char(1),
    IN description varchar(10)
) RETURNS RECORD AS $$

DECLARE
    account accounts%ROWTYPE;
    ret RECORD;
    amountInsert integer;
BEGIN
    SELECT * FROM accounts WHERE id = account_id INTO account;

    IF not found THEN
        SELECT -1, 0, 0 INTO ret;
        RETURN ret;
    END IF;

    SELECT amount INTO amountInsert;

    IF kind = 'd' THEN
        amountInsert = -amountInsert;
    END IF;

    UPDATE accounts
    SET current_balance = accounts.current_balance + amountInsert
    WHERE id = account_id AND (amountInsert > 0 OR accounts.limit_amount + accounts.current_balance >= amount)
        RETURNING 1, limit_amount, current_balance INTO ret;

    IF ret.limit_amount is NULL THEN
        SELECT -2, 0, 0 INTO ret;
        RETURN ret;
    END IF;

    INSERT INTO transactions (account_id, amount, transaction_type, description)
    VALUES (account_id, amount, kind, description);

    RETURN ret;
END;$$ LANGUAGE plpgsql;