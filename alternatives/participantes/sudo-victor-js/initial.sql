CREATE TABLE IF NOT EXISTS members (
  id serial primary key,
  nome varchar(255) not null,
  limit bigint not null,
  current_balance bigint not null,
  versao integer not null default 0
);

CREATE TABLE IF NOT EXISTS transactions (
  id serial primary key,
  cliente_id integer not null,
  amount bigint not null,
  kind char not null,
  description varchar not null,
  submitted_at timestamp not null,
  FOREIGN KEY(cliente_id) REFERENCES members(id)
);

INSERT INTO members (id, nome, limit, current_balance) VALUES
(1, 'Cliente 1', 100000, 0),
(2, 'Cliente 2', 80000, 0),
(3, 'Cliente 3', 1000000, 0),
(4, 'Cliente 4', 10000000, 0),
(5, 'Cliente 5', 500000, 0);