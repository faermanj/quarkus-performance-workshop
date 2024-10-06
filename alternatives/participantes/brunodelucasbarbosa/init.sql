-- Coloque scripts iniciais aqui
CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  limit INTEGER NOT NULL
);

CREATE TABLE transactions (
  cliente_id INT NOT NULL,
	amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
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
END; $$