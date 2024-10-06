CREATE TABLE tb_user (
    id INT PRIMARY KEY,
    limit BIGINT,
    current_balance BIGINT
);

CREATE TABLE tb_transaction (
    id SERIAL PRIMARY KEY,
    cliente_id INT,
    amount BIGINT,
    kind char(1),
    description varchar(10),
    submitted_at TIMESTAMP WITH TIME ZONE
);

INSERT INTO tb_user (id, limit, current_balance) VALUES(1, 100000, 0);
INSERT INTO tb_user (id, limit, current_balance) VALUES(2, 80000, 0);
INSERT INTO tb_user (id, limit, current_balance) VALUES(3, 1000000, 0);
INSERT INTO tb_user (id, limit, current_balance) VALUES(4, 10000000, 0);
INSERT INTO tb_user (id, limit, current_balance) VALUES(5, 500000, 0);