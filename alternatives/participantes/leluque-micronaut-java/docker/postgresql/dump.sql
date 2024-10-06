CREATE UNLOGGED TABLE conta (
                        id_cliente INT PRIMARY KEY NOT NULL,
                        current_balance_inicial_em_centavos BIGINT NOT NULL,
                        limit_em_centavos BIGINT NOT NULL,
                        current_balance_atual_em_centavos BIGINT NOT NULL
);

CREATE UNLOGGED TABLE transacao (
                            id BIGSERIAL PRIMARY KEY NOT NULL,
                            amount_em_centavos BIGINT NOT NULL,
                            kind CHAR(1) NOT NULL,
                            description VARCHAR(10),
                            submitted_at TIMESTAMP WITH TIME ZONE NOT NULL,
                            id_cliente INT NOT NULL,
                            FOREIGN KEY (id_cliente) REFERENCES conta(id_cliente)
);

-- CREATE INDEX idx_transacao_id_cliente ON transacao(id_cliente);

-----------------------------
-- Procedimento de atualização do current_balance e inclusão da transação.

CREATE OR REPLACE PROCEDURE atualizar_current_balance_e_inserir_transacao(
    _id_cliente BIGINT,
    _amount_em_centavos BIGINT,
    _kind CHAR(1),
    _description VARCHAR(10),
    INOUT _retorno VARCHAR(100))
LANGUAGE plpgsql AS $$
DECLARE
    v_current_balance_atual INT;
    v_limit INT;
BEGIN
    IF _kind = 'd' THEN
        UPDATE conta
        SET current_balance_atual_em_centavos = current_balance_atual_em_centavos - _amount_em_centavos
        WHERE id_cliente = _id_cliente
          AND current_balance_atual_em_centavos - _amount_em_centavos >= -limit_em_centavos
            RETURNING current_balance_atual_em_centavos, limit_em_centavos INTO v_current_balance_atual, v_limit;
    ELSE
        UPDATE conta
        SET current_balance_atual_em_centavos = current_balance_atual_em_centavos + _amount_em_centavos
        WHERE id_cliente = _id_cliente
            RETURNING current_balance_atual_em_centavos, limit_em_centavos INTO v_current_balance_atual, v_limit;
    END IF;

    -- Só não retornará se não tiver current_balance suficiente. A existência do cliente é verificada na aplicação.
    IF NOT FOUND THEN
      _retorno = 'SI'; -- Saldo insuficiente.
      RETURN;
    ELSE
      -- Insere a nova transação.
      INSERT INTO transacao (id_cliente, submitted_at, amount_em_centavos, kind, description) VALUES (_id_cliente, NOW(), _amount_em_centavos, _kind, _description);
      COMMIT;
      _retorno = CONCAT(v_current_balance_atual::varchar, ':', v_limit::varchar);
    END IF;
END;
$$;

-----------------------------
-- Inserção de dados de teste.

INSERT INTO conta (id_cliente, current_balance_inicial_em_centavos, limit_em_centavos, current_balance_atual_em_centavos)
VALUES
    (1, 0, 100000, 0),
    (2, 0, 80000, 0),
    (3, 0, 1000000, 0),
    (4, 0, 10000000, 0),
    (5, 0, 500000, 0);