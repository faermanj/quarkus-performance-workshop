CREATE TABLE members(
  id SERIAL PRIMARY KEY,
  nome varchar(100) NOT NULL,
  limite INT NOT NULL,
  saldo INT NOT NULL DEFAULT 0
  CONSTRAINT saldo_maior_ou_igual_limite CHECK (saldo >= -limite) 
);

CREATE TABLE transactions(
  id  SERIAL PRIMARY KEY,
  cliente_id INT NOT NULL,
  valor INT NOT NULL,
  tipo  CHAR(1) NOT NULL,
  descricao   VARCHAR(10) NOT NULL,
  realizada_em  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_members_transactions_id
      FOREIGN KEY (cliente_id) REFERENCES members(id)
);

INSERT INTO members (nome, limite)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);



