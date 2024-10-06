CREATE UNLOGGED TABLE tb_cliente (
                            cliente_id BIGSERIAL PRIMARY KEY,
                            limit BIGINT NOT NULL,
                            current_balance BIGINT NOT NULL
);

CREATE UNLOGGED TABLE tb_transacao (
                              transacao_id SERIAL PRIMARY KEY,
                              amount BIGINT NOT NULL,
                              kind VARCHAR(255) NOT NULL,
                              description VARCHAR(255) NOT NULL,
                              submitted_at TIMESTAMP NOT NULL,
                              cliente_id BIGINT NOT NULL,
                              FOREIGN KEY (cliente_id) REFERENCES tb_cliente(cliente_id)
);

CREATE INDEX idx_cliente_id ON tb_transacao (cliente_id);

DO $$
BEGIN
INSERT INTO tb_cliente (current_balance, limit) VALUES (0, 100000);
INSERT INTO tb_cliente (current_balance, limit) VALUES (0, 80000);
INSERT INTO tb_cliente (current_balance, limit) VALUES (0, 1000000);
INSERT INTO tb_cliente (current_balance, limit) VALUES (0, 10000000);
INSERT INTO tb_cliente (current_balance, limit) VALUES (0, 500000);
END $$;
