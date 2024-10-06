DROP TABLE IF EXISTS transactions;
--
DROP TABLE IF EXISTS clientes;

CREATE UNLOGGED TABLE IF NOT EXISTS clientes (
    id SERIAL NOT NULL,
    limit INTEGER NOT NULL,
	current_balance INTEGER NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
    id SERIAL NOT NULL,
    id_clientes BIGINT NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10),
    submitted_at TIMESTAMP NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_clientes
        FOREIGN KEY(id_clientes)
        REFERENCES clientes(id)
);

DO $$
BEGIN
    INSERT INTO clientes (id, limit, current_balance)
    VALUES
       (1, 1000 * 100, 0)
      ,(2, 800 * 100, 0)
      ,(3, 10000 * 100, 0)
      ,(4, 100000 * 100, 0)
      ,(5, 5000 * 100, 0);
END; $$
