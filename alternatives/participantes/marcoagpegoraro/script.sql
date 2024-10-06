CREATE UNLOGGED TABLE cliente (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(30) NOT NULL,
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE transacao (
    id SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    amount INTEGER NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_clientes_transactions_id
        FOREIGN KEY (id_cliente) REFERENCES cliente(id)
);

CREATE INDEX IF NOT EXISTS idx_cliente_id ON cliente(id);
CREATE INDEX IF NOT EXISTS idx_transacao_id_cliente_submitted_at_desc ON transacao(id_cliente, submitted_at DESC);


CREATE OR REPLACE FUNCTION update_balance(id_cliente INT, kind_transacao CHAR(1), amount_transacao NUMERIC, OUT text_message TEXT, OUT is_error BOOLEAN, OUT updated_balance NUMERIC, OUT client_limit NUMERIC) AS $$
DECLARE
    client_record RECORD;
    limit_cliente NUMERIC;
    current_balance_cliente NUMERIC;
BEGIN
    SELECT * INTO client_record FROM cliente WHERE id = id_cliente FOR UPDATE;
    IF NOT FOUND THEN
        text_message := 'Cliente não encontrado';
        is_error := true;
        updated_balance := 0;
        client_limit := 0;
        RETURN;
    END IF;
    limit_cliente := client_record.limit;
    IF kind_transacao = 'c' THEN
        current_balance_cliente := client_record.current_balance + amount_transacao;
    ELSIF kind_transacao = 'd' THEN
        current_balance_cliente := client_record.current_balance - amount_transacao;
        IF limit_cliente + current_balance_cliente < 0 THEN
            text_message := 'Limite foi ultrapassado';
            is_error := true;
            updated_balance := 0;
            client_limit := 0;
            RETURN;
        END IF;
    END IF;
    UPDATE cliente SET current_balance = current_balance_cliente WHERE id = id_cliente;
    text_message := 'Saldo do cliente atualizado com sucesso';
    is_error := false;
    updated_balance := current_balance_cliente;
    client_limit := limit_cliente;
END;
$$ LANGUAGE plpgsql;

INSERT INTO cliente (id, nome, limit, current_balance) VALUES
	(1, 'o barato sai caro', 1000 * 100, 0),
	(2, 'zan corp ltda', 800 * 100, 0),
	(3, 'les cruders', 10000 * 100, 0),
	(4, 'padaria joia de cocaia', 100000 * 100, 0),
	(5, 'kid mais', 5000 * 100, 0);
