CREATE TABLE IF NOT EXISTS clientes (
	id SERIAL PRIMARY KEY,
	limit INT,
	current_balance INT,
	version INT DEFAULT 0,
	created_at TIMESTAMP
);


CREATE TABLE IF NOT EXISTS transactions (
	id SERIAL PRIMARY KEY,
	cliente_id INT NOT NULL,
	amount INT NOT NULL,
	kind CHAR(1) NOT NULL,
	description VARCHAR(10) NOT NULL,
	submitted_at TIMESTAMP NOT NULL,
  	created_at TIMESTAMP,
  	updated_at TIMESTAMP,
	FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

INSERT INTO clientes (id, limit, current_balance) VALUES
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);
