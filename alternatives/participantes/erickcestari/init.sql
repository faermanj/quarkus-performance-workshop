DO $$
BEGIN 
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

    INSERT INTO clientes (nome, limit, current_balance)
    VALUES
        ('Erick', 100000, 0),
        ('Vinicius', 80000, 0),
        ('Leonardo', 1000000, 0),
        ('Bob', 10000000, 0),
        ('Tom', 500000, 0);
END $$;