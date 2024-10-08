CREATE TABLE IF NOT EXISTS clientes (
	cliente_id BIGSERIAL PRIMARY KEY,
	nome VARCHAR(50),
	limit INT DEFAULT 0,
	current_balance INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS transactions (
	transactions_id BIGSERIAL PRIMARY KEY,
	cliente_id INT,
	amount INT,
	kind VARCHAR(1),
	description VARCHAR(10),
	submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

INSERT INTO clientes (nome, limit) VALUES
  	('o barato sai caro', 1000 * 100),
  	('zan corp ltda', 800 * 100),
  	('les cruders', 10000 * 100),
  	('padaria joia de cocaia', 100000 * 100),
  	('kid mais', 5000 * 100);

