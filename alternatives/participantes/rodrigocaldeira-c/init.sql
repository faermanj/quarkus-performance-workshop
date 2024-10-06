CREATE TABLE IF NOT EXISTS members
(
    id integer NOT NULL,
    nome varchar(50) NOT NULL,
    limit integer NOT NULL,
    saldo integer NOT NULL DEFAULT 0,
    recent_transactions jsonb[] DEFAULT ARRAY[]::jsonb[],
    CONSTRAINT members_pkey PRIMARY KEY (id),
    CONSTRAINT saldo_maior_que_o_limit CHECK (saldo >= (limit * '-1'::integer))
);

DO $$
BEGIN
  INSERT INTO members ("id", "nome", "limit")
  VALUES
    (1, 'o barato sai caro', 1000 * 100),
    (2, 'zan corp ltda', 800 * 100),
    (3, 'les cruders', 10000 * 100),
    (4, 'padaria joia de cocaia', 100000 * 100),
    (5, 'kid mais', 5000 * 100);
END; $$
