CREATE TABLE members (
     id SERIAL PRIMARY KEY,
     limit INTEGER NOT NULL,
     current_balance INTEGER NOT NULL
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  cliente_id INTEGER REFERENCES members(id),
  amount INTEGER NOT NULL,
  kind VARCHAR NOT NULL,
  description VARCHAR(10) NOT NULL,
  data VARCHAR NOT NULL
);

insert into members
(id, limit, current_balance)
values
    (1, 100000, 0),
    (2, 80000, 0),
    (3, 1000000, 0),
    (4, 10000000, 0),
    (5, 500000, 0)