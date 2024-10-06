 -- Criar tabela clientes
    CREATE TABLE IF NOT EXISTS clientes (
        id SERIAL PRIMARY KEY,
        limit INT NOT NULL,
        current_balance INT DEFAULT 0,
        nome VARCHAR(50) NOT NULL
    );
    
    
    -- Criar tabela transactions
    CREATE TABLE IF NOT EXISTS transactions (
        id SERIAL PRIMARY KEY,
        amount INT NOT NULL,
        kind VARCHAR(1) NOT NULL,
        submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
        description VARCHAR(10) NOT NULL,
        cliente_id INT NOT NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id)
    );
    DO $$
    BEGIN
        INSERT INTO clientes (nome, limit)
        VALUES
            ('o barato sai caro', 1000 * 100),
            ('zan corp ltda', 800 * 100),
            ('les cruders', 10000 * 100),
            ('padaria joia de cocaia', 100000 * 100),
            ('kid mais', 5000 * 100);
        
    END;
    $$;
