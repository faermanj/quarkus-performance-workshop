CREATE UNLOGGED TABLE clientes (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    created_at timestamp with time zone,
    limit bigint,
    current_balance bigint
);

CREATE UNLOGGED TABLE transactions (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    amount bigint,
    kind char(1),
    description char(10),
    cliente_id bigint
);

CREATE UNIQUE INDEX idx_cliente ON clientes (id);
CREATE INDEX idx_transacao_created_at ON transactions (created_at DESC);

INSERT INTO clientes (limit, current_balance) VALUES
  (100000, 0),
  (80000, 0),
  (1000000, 0),
  (10000000, 0),
  (500000, 0);
