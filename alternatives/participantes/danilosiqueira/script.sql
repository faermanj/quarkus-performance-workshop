CREATE TABLE clientes (
  id serial not null primary key,
  nome varchar(100) not null,
  limit bigint not null default 0,
  current_balance bigint not null default 0
);

CREATE TABLE transactions (
  id serial not null primary key,
  amount bigint not null,
  kind char(1) not null,
  description varchar(10),
  submitted_at timestamp not null default CURRENT_TIMESTAMP,
  cliente_id integer not null references clientes (id)
);

CREATE INDEX idx_transactions_cliente_id ON transactions (cliente_id);

DO $$
BEGIN
  INSERT INTO clientes (nome, limit)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$