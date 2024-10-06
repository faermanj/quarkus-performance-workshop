CREATE TABLE cliente (
  id INT PRIMARY KEY,
  limit BIGINT NOT NULL,
  current_balance BIGINT NOT NULL
);

CREATE TABLE transacao (
  id SERIAL PRIMARY KEY,
  id_cliente INT NOT NULL,
  amount BIGINT NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  realizado_em TIMESTAMP WITH TIME ZONE NOT NULL,
  current_balance BIGINT NOT NULL
);

CREATE INDEX transacao_index ON transacao (
  id_cliente
);

INSERT INTO cliente (id, limit, current_balance) VALUES (1, 100000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (2, 80000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (3, 1000000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (4, 10000000, 0);
INSERT INTO cliente (id, limit, current_balance) VALUES (5, 500000, 0);
