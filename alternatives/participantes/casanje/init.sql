CREATE TABLE members (
  id serial4 NOT NULL,
  nome varchar(50) NOT NULL,
  limit int4 NOT NULL,
  current_balance int4 NOT NULL DEFAULT 0,
  CONSTRAINT members_pkey PRIMARY KEY (id)
);

CREATE TABLE transactions (
  id serial4 NOT NULL,
  cliente_id int4 NOT NULL,
  amount int4 NOT NULL DEFAULT 0,
  description varchar(10) NOT NULL,
  kind varchar(1) NOT NULL,
  submitted_at date NOT NULL DEFAULT 'now' :: text :: date,
  CONSTRAINT transactions_pkey PRIMARY KEY (id)
);

INSERT INTO
  members (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100);

INSERT INTO
  members (nome, limit)
VALUES
  ('zan corp ltda', 800 * 100);

INSERT INTO
  members (nome, limit)
VALUES
  ('les cruders', 10000 * 100);

INSERT INTO
  members (nome, limit)
VALUES
  ('padaria joia de cocaia', 100000 * 100);

INSERT INTO
  members (nome, limit)
VALUES
  ('kid mais', 5000 * 100);