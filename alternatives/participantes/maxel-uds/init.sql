DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
	id INTEGER PRIMARY KEY,
	current_balance INTEGER,
	limit INTEGER
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	user_id INTEGER,
	amount INTEGER,
	kind VARCHAR(1),
	description VARCHAR(10),
	criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO users (id, limit, current_balance)
VALUES
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);