CREATE EXTENSION IF NOT EXISTS pg_prewarm;

CREATE TABLE IF NOT EXISTS cliente (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(50) NOT NULL,
  limit INT DEFAULT 0 NOT NULL,
  current_balance INT DEFAULT 0 NOT NULL
);

CREATE TABLE IF NOT EXISTS transacao (
  id SERIAL PRIMARY KEY,
  id_cliente INT,
  amount INT DEFAULT 0 NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (id_cliente) REFERENCES cliente(id)
);

INSERT INTO
  cliente (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);

SELECT
  pg_prewarm ('cliente');

SELECT
  pg_prewarm ('transacao');