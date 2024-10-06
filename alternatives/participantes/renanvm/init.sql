CREATE TABLE Cliente (
                       id INTEGER PRIMARY KEY,
                       limit INTEGER,
                       current_balance INTEGER
);

INSERT INTO Cliente (id, limit, current_balance)
VALUES (1, 100000, 0),
       (2, 80000, 0),
       (3, 1000000, 0),
       (4, 10000000, 0),
       (5, 500000, 0);

CREATE TABLE Transacao (
                           id SERIAL PRIMARY KEY,
                           cliente_id INTEGER,
                           amount INTEGER NOT NULL,
                           kind VARCHAR(255) NOT NULL,
                           description VARCHAR(255),
                           submitted_at TIMESTAMP
);
