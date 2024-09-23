DROP TABLE IF EXISTS members;

CREATE TABLE members (
  id SERIAL PRIMARY KEY,
  limite INT NOT NULL,
  saldo INT DEFAULT 0 NOT NULL,
  transactions TEXT NOT NULL DEFAULT '[]'
);

CREATE UNIQUE INDEX idx_members_id ON members USING btree (id);

INSERT INTO members (limite) VALUES
  (1000 * 100),
  (800 * 100),
  (10000 * 100),
  (100000 * 100),
  (5000 * 100);