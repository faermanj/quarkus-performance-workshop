-- Cria o banco de dados
-- CREATE DATABASE rinha;

-- Conecta ao banco de dados
\c rinha;

-- Script para criar as tabelas

-- Cria a tabela members
CREATE TABLE IF NOT EXISTS members (
    id SERIAL PRIMARY KEY,
    limite INTEGER NOT NULL,
    saldo INTEGER NOT NULL
);

-- Cria a tabela transactions
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    valor INTEGER NOT NULL,
    tipo CHAR(1) CHECK(tipo IN ('c', 'd')) NOT NULL,
    descricao VARCHAR(10) NOT NULL,
    realizado_em TIMESTAMP WITH TIME ZONE NOT NULL,
    cliente_id INTEGER,
    FOREIGN KEY (cliente_id) REFERENCES members(id)
);

INSERT INTO members (id, limite, saldo) VALUES
(1, 100000, 0),
(2, 80000, 0),
(3, 1000000, 0),
(4, 10000000, 0),
(5, 500000, 0);