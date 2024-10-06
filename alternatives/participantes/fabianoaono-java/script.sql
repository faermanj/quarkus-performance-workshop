CREATE TABLE cliente (
  id BIGINT PRIMARY KEY,
  limit INTEGER,
  current_balance INTEGER
);

CREATE TABLE transacao (
  id BIGINT PRIMARY KEY,
  cliente_id BIGINT NOT NULL,
  description VARCHAR(10) NOT NULL,
  kind VARCHAR(1) NOT NULL,
  amount INTEGER NOT NULL,
  submitted_at TIMESTAMP NOT NULL,
  FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE SEQUENCE Cliente_SEQ START with 1 INCREMENT BY 50;
CREATE SEQUENCE Transacao_SEQ START with 1 INCREMENT BY 50;

INSERT INTO cliente (id, limit, current_balance) VALUES
  (1, 1000   * 100, 0),
  (2, 800    * 100, 0),
  (3, 10000  * 100, 0),
  (4, 100000 * 100, 0),
  (5, 5000   * 100, 0);

