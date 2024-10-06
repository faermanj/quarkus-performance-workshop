CREATE UNLOGGED TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(30) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    amount INTEGER NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_transactions ON transactions (cliente_id, submitted_at desc);

CREATE OR REPLACE FUNCTION inserir_transcacao(cliente INTEGER, kind CHAR(1), amount INTEGER, description VARCHAR(10))
RETURNS TABLE(current_balance_novo INTEGER, limit INTEGER, erro BOOLEAN) AS $$
DECLARE
  current_balance_atual INTEGER;
  limit INTEGER;
  current_balance_novo INTEGER;
BEGIN
    SELECT c.current_balance, c.limit INTO current_balance_atual, limit FROM clientes c WHERE c.id = cliente FOR UPDATE;

    IF kind = 'd' THEN
        current_balance_novo := current_balance_atual - amount;
    ELSE
        current_balance_novo := current_balance_atual + amount;
    END IF;

    IF current_balance_novo + limit >= 0 THEN
        UPDATE clientes SET current_balance = current_balance_novo WHERE id = cliente;

        INSERT INTO transactions (cliente_id, kind, amount, description) VALUES (cliente, kind, amount, description);

        RETURN QUERY SELECT current_balance_novo, limit, false;
    ELSE
        RETURN QUERY SELECT 0, 0, true;
    END IF;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  INSERT INTO clientes (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$