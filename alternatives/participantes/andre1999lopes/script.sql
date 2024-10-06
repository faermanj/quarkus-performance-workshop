CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  limit int NOT NULL,
  current_balance int NOT NULL
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  usuario_id INT NOT NULL REFERENCES usuarios(id),
  amount int NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP NOT NULL
);

INSERT INTO usuarios (nome, limit, current_balance) VALUES
  ('o barato sai caro', 100000, 0),
  ('zan corp ltda', 80000, 0),
  ('les cruders', 1000000, 0),
  ('padaria joia de cocaia', 10000000, 0),
  ('kid mais', 500000, 0);