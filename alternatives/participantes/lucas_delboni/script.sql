DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
	id BIGSERIAL PRIMARY KEY,
	limit NUMERIC NOT NULL,
	current_balance NUMERIC NOT NULL DEFAULT 0,
	CONSTRAINT current_balance_nao_negativo check (current_balance >= (limit * -1))--o que me permite usar ON CONFLICT
);

CREATE TABLE transactions (
	id BIGSERIAL PRIMARY KEY,
	cliente_id BIGINT NOT NULL,
	amount NUMERIC NOT NULL,
	kind BOOLEAN NOT NULL,--1 se D, 0 se C
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_clientes_transactions_id
		FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);


--talvez criar uma view materialized para as 10 ultimas transações...



DO $$
BEGIN
  INSERT INTO clientes (id, limit)
  VALUES
    (1, 1000 * 100),
    (2, 800 * 100),
    (3, 10000 * 100),
    (4, 100000 * 100),
    (5, 5000 * 100);
END; $$
