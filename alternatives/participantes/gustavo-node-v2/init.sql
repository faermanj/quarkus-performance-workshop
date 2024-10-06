CREATE TABLE clientes (
  id SERIAL PRIMARY KEY NOT NULL,
  nome VARCHAR(23) NOT NULL, 
  limit INTEGER NOT NULL CHECK (limit >= 0),
  current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY NOT NULL,
  id_cliente INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10),
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL,

  CONSTRAINT clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id)
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
