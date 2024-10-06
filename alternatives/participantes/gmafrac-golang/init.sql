CREATE UNLOGGED TABLE clientes (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    limit INTEGER NOT NULL,
    current_balance INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE transactions (
    id SERIAL PRIMARY KEY NOT NULL,
    cliente_id INT NOT NULL,
    amount INTEGER NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(10) ,
    submitted_at timestamp with time zone DEFAULT now(),
    CONSTRAINT fk_clientes FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id)
);

DO $$
BEGIN
  INSERT INTO clientes (limit)
  VALUES
    (1000 * 100),
    (800 * 100),
    (10000 * 100),
    (100000 * 100),
    (5000 * 100);
END; $$