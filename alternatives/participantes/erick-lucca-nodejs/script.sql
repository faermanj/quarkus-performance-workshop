CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255),
    limit INT,
    current_balance INT DEFAULT 0
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    id_cliente INT REFERENCES clientes(id),
    kind VARCHAR(1),
    description VARCHAR(10),
    amount INT,
    submitted_at TIMESTAMP
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
END; $$