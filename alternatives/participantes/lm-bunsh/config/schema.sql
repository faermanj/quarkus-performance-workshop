CREATE TABLE IF NOT EXISTS Clientes (
    id INTEGER PRIMARY KEY,
    current_balance INTEGER,
    limit INTEGER
);

CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY,
    amount INTEGER,
    kind VARCHAR(1),
    description VARCHAR(10),
    clienteId INTEGER,
    submitted_at DATE,
    FOREIGN KEY (clienteId) REFERENCES Clientes(id)
);

INSERT OR IGNORE INTO Clientes (id, current_balance, limit) VALUES (1, 0, 100000);
INSERT OR IGNORE INTO Clientes (id, current_balance, limit) VALUES (2, 0, 80000);
INSERT OR IGNORE INTO Clientes (id, current_balance, limit) VALUES (3, 0, 1000000);
INSERT OR IGNORE INTO Clientes (id, current_balance, limit) VALUES (4, 0, 10000000);
INSERT OR IGNORE INTO Clientes (id, current_balance, limit) VALUES (5, 0, 500000);