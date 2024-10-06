
-- Criação da tabela de clientes
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    limit INT,
    current_balance INT
);


-- Criação da tabela de histórico de transações
CREATE TABLE historico_transactions (
    id SERIAL,
    id_cliente INT,
    amount INT,
    kind CHAR(1),
    description VARCHAR(10),
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id, id_cliente) -- Inclua a coluna id_cliente na chave primária
) PARTITION BY LIST (id_cliente);

CREATE TABLE historico_transactions_cliente_1 PARTITION OF historico_transactions
    FOR VALUES IN (1);
CREATE TABLE historico_transactions_cliente_2 PARTITION OF historico_transactions
    FOR VALUES IN (2);
CREATE TABLE historico_transactions_cliente_3 PARTITION OF historico_transactions
    FOR VALUES IN (3);
CREATE TABLE historico_transactions_cliente_4 PARTITION OF historico_transactions
    FOR VALUES IN (4);     
CREATE TABLE historico_transactions_cliente_5 PARTITION OF historico_transactions
    FOR VALUES IN (5);     

-- Inserção de dados iniciais na tabela de clientes
INSERT INTO clientes (name, limit, current_balance) VALUES
    ('Italo', 100000, 0),
    ('Carla', 80000, 0),
    ('Monica', 1000000, 0),
    ('Haroldo', 10000000, 0),
    ('Mariana', 500000, 0);
