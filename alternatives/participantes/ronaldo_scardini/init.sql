CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL,
    limit INTEGER NOT NULL
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE current_balances (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER UNIQUE NOT NULL,
    amount INTEGER NOT NULL
);

---------- INSERTS

DO $$
BEGIN
    INSERT INTO members (nome, limit)
    VALUES
        ('o barato sai caro', 1000 * 100),
        ('zan corp ltda', 800 * 100),
        ('les cruders', 10000 * 100),
        ('padaria joia de cocaia', 100000 * 100),
        ('kid mais', 5000 * 100);
    
    INSERT INTO current_balances (cliente_id, amount) SELECT id, 0 FROM members;
END;
$$;

---------- PROCEDURES

CREATE PROCEDURE atualizar_current_balance(v1 INT, i INT, v2 INT, t CHAR, d VARCHAR(10))
    LANGUAGE SQL
    BEGIN ATOMIC
    UPDATE current_balances SET amount = amount + v1 WHERE cliente_id = i;
    INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (i, v2, t, d);
END;

---------- FUNCTIONS

CREATE FUNCTION realizar_transacao(v1 INT, i INT, v2 INT, t CHAR, d VARCHAR(10), l INT, OUT st INT, OUT sa INT)
LANGUAGE plpgsql 
AS $$
DECLARE current_balance_atual INT;
DECLARE current_balance_atualizado INT;
BEGIN
    SELECT current_balances.amount into current_balance_atual from current_balances where cliente_id = i FOR UPDATE;
    IF t = 'd' AND (current_balance_atual - v2) < (l * -1) THEN
        st := 0;
        sa := 0;
        RETURN;
    END IF;
    UPDATE current_balances SET amount = amount + v1 WHERE cliente_id = i;
    current_balance_atualizado := current_balance_atual + v1;
    INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (i, v2, t, d);
    st := 1;
    sa := current_balance_atualizado;
    RETURN;
END;
$$;