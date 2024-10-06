CREATE TABLE clientes (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(30) NOT NULL,
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE transactions(
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cliente_id FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
-- CREATE UNIQUE INDEX idx_clientes_id ON clientes USING btree (id);
CREATE INDEX idx_transactions_cliente_id ON transactions USING btree (cliente_id);

INSERT INTO clientes (nome, limit)
VALUES
  ('o barato sai caro', 1000 * 100),
  ('zan corp ltda', 800 * 100),
  ('les cruders', 10000 * 100),
  ('padaria joia de cocaia', 100000 * 100),
  ('kid mais', 5000 * 100);

-- CREATE OR REPLACE FUNCTION apagar_registro_mais_antigo() RETURNS TRIGGER AS $$
-- BEGIN
--     IF (SELECT count(*) FROM transactions) > 10 THEN
--         DELETE FROM transactions
--         WHERE id = (SELECT id FROM transactions ORDER BY submitted_at ASC LIMIT 1);
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER trigger_apagar_registro_mais_antigo
-- AFTER INSERT ON transactions
-- FOR EACH ROW
-- EXECUTE FUNCTION apagar_registro_mais_antigo();
