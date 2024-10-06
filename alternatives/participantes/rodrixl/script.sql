
    DROP TABLE IF EXISTS cliente;
    CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
        id SERIAL PRIMARY KEY NOT NULL,
        nome VARCHAR(50) NOT NULL,
        limit INTEGER NOT NULL,
        current_balance INTEGER NOT NULL
    );

    DROP TABLE IF EXISTS transaction;
    CREATE UNLOGGED TABLE IF NOT EXISTS transaction (
        id SERIAL PRIMARY KEY NOT NULL,
        amount INTEGER NOT NULL,
        kind CHAR(1) NOT NULL,
        description VARCHAR(10) NOT NULL,
        submitted_at TIMESTAMPTZ NOT NULL,
        cliente_id INTEGER NOT NULL
        );

    -- Inserção de amountes iniciais na tabela members
    INSERT INTO cliente (nome, limit, current_balance)
    VALUES
        ('Cliente1', 100000, 0),
        ('Cliente2', 80000, 0),
        ('Cliente3', 1000000, 0),
        ('Cliente4', 10000000, 0),
        ('Cliente5', 500000, 0);

    CREATE INDEX transacindex ON transaction (cliente_id);
    
    SELECT * FROM transaction;
    SELECT * FROM cliente;