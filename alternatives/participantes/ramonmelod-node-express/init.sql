CREATE TABLE members(
  id SERIAL PRIMARY KEY,
  nome varchar(100) NOT NULL,
  limit INT NOT NULL,
  current_balance INT NOT NULL DEFAULT 0
  CONSTRAINT current_balance_maior_ou_igual_limit CHECK (current_balance >= -limit) 
);

CREATE TABLE transactions(
  id  SERIAL PRIMARY KEY,
  cliente_id INT NOT NULL,
  amount INT NOT NULL,
  kind  CHAR(1) NOT NULL,
  description   VARCHAR(10) NOT NULL,
  submitted_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_members_transactions_id
      FOREIGN KEY (cliente_id) REFERENCES members(id)
);

INSERT INTO members (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);



