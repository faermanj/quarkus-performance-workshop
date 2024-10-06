
CREATE UNLOGGED TABLE public.cliente (
    id serial PRIMARY KEY,
    limit int NOT NULL,
    current_balance_inicial int NOT NULL
);
 CREATE INDEX members_id_idx ON cliente (id);

INSERT INTO public.cliente (limit, current_balance_inicial)
VALUES
(100000, 0),
(80000, 0),
(1000000, 0),
(10000000, 0),
(500000, 0);

CREATE UNLOGGED TABLE public.historico_cliente (
    id SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    kind CHAR(1) NOT NULL,
    description VARCHAR(10) NOT NULL,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_transactions_cliente_id ON public.historico_cliente (id_cliente);

ALTER TABLE ONLY public.historico_cliente
    ADD CONSTRAINT historico_cliente_fk FOREIGN KEY (id_cliente) REFERENCES cliente(id);
	
	
CREATE OR REPLACE FUNCTION ExecutarTransacao(id_cliente INTEGER, amount INTEGER, kind CHAR, description TEXT)
RETURNS TABLE (limit INTEGER, current_balance_inicial INTEGER) AS $$
DECLARE
    limitAtual INTEGER;
    current_balanceAtual INTEGER;
BEGIN    
    SELECT cliente.limit, cliente.current_balance_inicial INTO limitAtual, current_balanceAtual FROM public.cliente WHERE id = id_cliente FOR UPDATE;

    IF kind = 'd' THEN
        current_balanceAtual := current_balanceAtual - amount;
    ELSE
        current_balanceAtual := current_balanceAtual + amount;
    END IF;

    IF current_balanceAtual < 0 AND ABS(current_balanceAtual) > limitAtual THEN
        RETURN;
    ELSE    
        INSERT INTO historico_cliente (id_cliente, amount, kind, description, submitted_at)
        VALUES (id_cliente, amount, kind, description, CURRENT_TIMESTAMP);

        UPDATE cliente SET current_balance_inicial = current_balanceAtual WHERE id = id_cliente;

        RETURN QUERY SELECT limitAtual, current_balanceAtual;
    END IF;
END;
$$ LANGUAGE plpgsql;


