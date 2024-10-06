CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  limit INT DEFAULT 0 NOT NULL,
  current_balance INT DEFAULT 0 NOT NULL,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  client_id SERIAL REFERENCES clients(id) NOT NULL,
  amount INT NOT NULL,
  description VARCHAR(10) NOT NULL,
  kind VARCHAR(1) NOT NULL,
  realizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX clients_id_index ON clients (id);
CREATE INDEX transactions_id_index ON transactions(id);
CREATE INDEX transactions_client_id_index ON transactions(client_id);
CREATE INDEX transactions_created_at_index ON transactions(realizado_em DESC);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('clients');
SELECT pg_prewarm( 'transactions');

INSERT INTO clients (limit, current_balance) VALUES (100000, 0);
INSERT INTO clients (limit, current_balance) VALUES (80000, 0);
INSERT INTO clients (limit, current_balance) VALUES (1000000, 0);
INSERT INTO clients (limit, current_balance) VALUES (10000000, 0);
INSERT INTO clients (limit, current_balance) VALUES (500000, 0);
