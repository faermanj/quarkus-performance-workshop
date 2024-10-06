--ALTER SYSTEM SET max_connections = 200;
CREATE TABLE if NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    limit INTEGER NOT NULL,
    current_balance INTEGER NOT NULL
  );

CREATE TABLE if NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  amount INTEGER NOT NULL,
  description VARCHAR(100) NOT NULL,
  kind VARCHAR(1) NOT NULL,
  submitted_at TIMESTAMP NOT NULL,
  cliente_id INTEGER NOT NULL REFERENCES members(id),
  FOREIGN KEY (cliente_id) REFERENCES members(id)
);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;
SELECT pg_prewarm('members');
SELECT pg_prewarm( 'transactions');

create or replace function altera_current_balance_cliente(
  cliente_id integer, 
  amount integer
		) returns integer
    AS $$
  declare
    current_balance_ integer;
    limit_ integer;
  begin
    select current_balance, limit into current_balance_, limit_ from members where id = cliente_id for update;
    if amount < 0 and abs(amount) >= sum(current_balance_ + limit_) then
      raise exception 'Saldo negativo';
    end if;
    update members set current_balance = current_balance_ + amount where id = cliente_id;
    return sum(current_balance_ + amount);

end; 
$$ LANGUAGE plpgsql;


DO $$
BEGIN
  
  INSERT INTO members (nome, limit, current_balance)
  VALUES
    ('o barato sai caro', 1000 * 100, 0),
    ('zan corp ltda', 800 * 100, 0),
    ('les cruders', 10000 * 100, 0),
    ('padaria joia de cocaia', 100000 * 100, 0),
    ('kid mais', 5000 * 100, 0);
END; $$
