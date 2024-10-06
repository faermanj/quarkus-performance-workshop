-- Coloque scripts iniciais aqui
CREATE TABLE clientes (
    id INT GENERATED ALWAYS AS IDENTITY,
    nome text NOT NULL,
    limit integer NOT NULL,
    current_balance integer NOT NULL default 0,
    PRIMARY KEY(id)
);

CREATE TABLE transactions (
    id INT GENERATED ALWAYS AS IDENTITY,
    amount integer NOT NULL,
    kind character(1) NOT NULL,
    description varchar(10) NOT NULL,
    submitted_at timestamp with time zone NOT NULL,
    cliente_id integer NOT NULL,
    PRIMARY KEY(id),
    CONSTRAINT fk_cliente
      FOREIGN KEY(cliente_id) 
        REFERENCES clientes(id)
);

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