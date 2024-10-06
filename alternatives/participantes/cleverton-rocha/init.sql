CREATE EXTENSION IF NOT EXISTS pg_prewarm;

CREATE TYPE public."TipoTransacao" AS ENUM ('c', 'd');

CREATE TABLE public."Cliente" (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255),
  limit INT DEFAULT 0,
  current_balance INT DEFAULT 0
);

CREATE TABLE public."Transacao" (
  id SERIAL PRIMARY KEY,
  id_cliente INT,
  amount INT DEFAULT 0,
  kind public."TipoTransacao",
  description VARCHAR(10),
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_cliente) REFERENCES public."Cliente"(id)
);

INSERT INTO public."Cliente" (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);
  
SELECT pg_prewarm ('public."Cliente"');

SELECT pg_prewarm ('public."Transacao"');