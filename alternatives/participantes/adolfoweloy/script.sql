-- clientes
CREATE sequence if NOT EXISTS clientes_sq increment BY 1 start 1;

CREATE TABLE if NOT EXISTS clientes(
  id INTEGER PRIMARY KEY DEFAULT nextval('clientes_sq'),
  nome VARCHAR(10),
  limite INTEGER,
  saldo INTEGER DEFAULT 0
);

ALTER sequence clientes_sq owned BY clientes.id;

-- transactions
CREATE SEQUENCE transactions_sq INCREMENT BY 1 START 1;

CREATE TABLE transactions(
  id INTEGER PRIMARY KEY DEFAULT nextval('transactions_sq'),
  cliente_id INTEGER REFERENCES clientes(id),
  valor INTEGER DEFAULT 0,
  tipo CHAR CHECK (tipo = 'c' OR tipo = 'd'),
  descricao VARCHAR(10),
  realizada_em TIMESTAMP WITH TIME ZONE
);

ALTER SEQUENCE transactions_sq OWNED BY transactions.id;

-- initial data
DO $$
BEGIN
  INSERT INTO clientes (nome, limite)
  VALUES
    ('furukawa', 100000),
    ('zen lah', 80000),
    ('loscrudos', 1000000),
    ('labamba', 10000000),
    ('pirocoptus', 500000);
END;
$$
