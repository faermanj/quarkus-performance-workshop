CREATE TABLE IF NOT EXISTS members (
  id INTEGER PRIMARY KEY AUTO_INCREMENT, 
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS transactions (
  id INTEGER PRIMARY KEY AUTO_INCREMENT,
  cliente_id INTEGER,
  amount INTEGER NOT NULL,
  kind ENUM('c', 'd') NOT NULL,
  description TEXT NOT NULL,
  submitted_at TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE transactions add foreign key(cliente_id) references members(id);

INSERT INTO members(limit, current_balance) VALUES (100000,0);
INSERT INTO members(limit, current_balance) VALUES (80000,0);
INSERT INTO members(limit, current_balance) VALUES (1000000,0);
INSERT INTO members(limit, current_balance) VALUES (10000000,0);
INSERT INTO members(limit, current_balance) VALUES (500000,0);