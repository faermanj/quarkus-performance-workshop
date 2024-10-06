CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    limit INT NOT NULL,
    current_balance INT
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    amount INT NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(100) NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES members(id)
);

DO $$
BEGIN
  INSERT INTO members (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$;