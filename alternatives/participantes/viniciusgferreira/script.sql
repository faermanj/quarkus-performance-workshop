-- Coloque scripts iniciais aqui
CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    limit int,
    current_balance int default 0,
    nome VARCHAR(100)
);

BEGIN;
INSERT INTO members (id, nome, limit)
VALUES
    (1, 'o barato sai caro', 1000 * 100),
    (2, 'zan corp ltda', 800 * 100),
    (3, 'les cruders', 10000 * 100),
    (4, 'padaria joia de cocaia', 100000 * 100),
    (5, 'kid mais', 5000 * 100);
COMMIT;

CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    cliente_id int NOT NULL,
    amount int NOT NULL,
    kind VARCHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

