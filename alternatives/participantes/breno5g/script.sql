DO $$
BEGIN 
    -- Criação de tabelas
    CREATE TABLE IF NOT EXISTS clientes (
        id SERIAL PRIMARY KEY NOT NULL,
        nome VARCHAR(50) NOT NULL,
        limit INTEGER NOT NULL,
        current_balance INTEGER NOT NULL
    );

    CREATE TABLE IF NOT EXISTS transactions (
        id SERIAL PRIMARY KEY NOT NULL,
        kind CHAR(1) NOT NULL,
        description VARCHAR(10) NOT NULL,
        amount INTEGER NOT NULL,
        cliente_id INTEGER NOT NULL,
        submitted_at TIMESTAMP NOT NULL DEFAULT NOW()
    );

    -- Inserção de amountes iniciais na tabela clientes
    INSERT INTO clientes (nome, limit, current_balance)
    VALUES
        ('Isadora', 100000, 0),
        ('Maicon', 80000, 0),
        ('Matias', 1000000, 0),
        ('Bob', 10000000, 0),
        ('Tom', 500000, 0);
END $$;