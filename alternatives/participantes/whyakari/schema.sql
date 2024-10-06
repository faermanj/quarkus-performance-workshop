CREATE TABLE IF NOT EXISTS members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    current_balance INT NOT NULL,
    limit INT NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    amount INT NOT NULL,
    id_cliente INT NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES members(id) ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO members (nome, limit, current_balance) VALUES
	('Akari', 100000 * 100, 0),
	('Isabella', 80000 * 100, 0),
	('Julia', 1000000 * 100, 0),
	('Hendrick', 10000000 * 100, 0),
	('Gustavo', 500000 * 100, 0);
