SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;
SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE UNLOGGED TABLE IF NOT EXISTS members (
  id SMALLINT PRIMARY KEY,
  limit INT NOT NULL,
  current_balance INT NOT NULL DEFAULT 0
  CONSTRAINT current_balance CHECK (current_balance > -limit)
);

CREATE INDEX pk_cliente_idx ON members (id) INCLUDE (current_balance);

INSERT INTO members (id, limit)
VALUES (1, 1000 * 100),
       (2, 800 * 100),
       (3, 10000 * 100),
       (4, 100000 * 100),
       (5, 5000 * 100)
ON CONFLICT DO NOTHING;

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  cliente_id SMALLINT NOT NULL,
  amount INT NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  FOREIGN KEY (cliente_id) REFERENCES members (id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id, id DESC);

CREATE OR REPLACE PROCEDURE adiciona_transacao(
  id_cliente SMALLINT,
  amount INTEGER,
  amount_balance INTEGER, 
  kind CHAR(1),
  description VARCHAR(10),
  OUT current_balance_atual INTEGER,
  OUT limit_atual INTEGER
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO transactions (cliente_id, amount, kind, description) VALUES (id_cliente, amount, kind, description);

  UPDATE members
     SET current_balance = current_balance + amount_balance
   WHERE id = id_cliente RETURNING current_balance, limit INTO current_balance_atual, limit_atual;

  COMMIT;
  RETURN;
END;
$$;