CREATE TABLE clientes (id SERIAL PRIMARY KEY, limit INT NOT NULL, current_balance INT NOT NULL);

INSERT INTO clientes (id, limit, current_balance) VALUES (1, 100000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (2, 80000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (3, 1000000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (4, 10000000, 0);
INSERT INTO clientes (id, limit, current_balance) VALUES (5, 500000, 0);

CREATE TABLE transactions (
    cliente_id INT NOT NULL, 
    kind CHAR NOT NULL, 
    description VARCHAR(10) NOT NULL, 
    amount INT NOT NULL, 
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
    CONSTRAINT fk_clientes FOREIGN KEY(cliente_id) REFERENCES clientes(id)
);

CREATE INDEX idx_client_id ON transactions(cliente_id);