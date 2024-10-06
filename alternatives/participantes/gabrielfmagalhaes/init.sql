CREATE TABLE clientes (
    id integer PRIMARY KEY NOT NULL,
    nome varchar(25) NOT NULL,
    current_balance integer NOT NULL,
    limit integer NOT NULL
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    clienteId integer NOT NULL,
    kind char(1) NOT NULL,
    amount integer NOT NULL,
    description varchar(10) NOT NULL,
    efetuadaEm timestamp NOT NULL
);

CREATE INDEX fk_transacao_clienteid ON transactions
(
    clienteId ASC
);

DELETE FROM transactions;
DELETE FROM clientes;

INSERT INTO clientes (id, nome, current_balance, limit)
  VALUES
    (1, 'o barato sai caro', 0, 1000 * 100),
    (2, 'zan corp ltda', 0, 800 * 100),
    (3, 'les cruders', 0, 10000 * 100),
    (4, 'padaria joia de cocaia', 0, 100000 * 100),
    (5, 'kid mais', 0, 5000 * 100);