CREATE UNLOGGED TABLE IF NOT EXISTS cliente (
	id bigint NOT NULL,
	limit bigint DEFAULT 0 NOT NULL,
	current_balance bigint DEFAULT 0 NOT NULL,
	CONSTRAINT cliente_pk PRIMARY KEY (id)
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacao (
	id bigserial NOT NULL,
	id_cliente bigint NOT NULL,
	description varchar(10) NULL,
	kind char(1) NOT NULL,
	amount bigint NOT NULL,
	submitted_at timestamp DEFAULT current_timestamp NULL,
	CONSTRAINT transacao_pk PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS transacao_id_cliente_idx ON transacao (id_cliente);

CREATE OR REPLACE FUNCTION registrar_transacao(
    p_id_cliente bigint,
    p_kind char(1),
    p_description varchar(10),
    p_amount bigint
)
RETURNS TABLE (
    out_limit_cliente bigint,
    out_novo_current_balance_cliente bigint,
    out_status varchar(2)
) AS
$$
declare
	v_id_cliente bigint;
BEGIN
	-- Atualiza o current_balance do cliente e obtem o novo current_balance
    UPDATE cliente
    SET current_balance = current_balance + (case when p_kind = 'd' then
                            -p_amount
                         else
                            p_amount
                         end)
    WHERE id = p_id_cliente
    RETURNING id, limit, current_balance INTO v_id_cliente, out_limit_cliente, out_novo_current_balance_cliente;

   	if v_id_cliente = null then
   		out_status = 'CI'; --cliente inexistete
   	else
	    -- Verifica se o novo current_balance ultrapassa o limit
	    IF p_kind = 'd' and out_novo_current_balance_cliente < 0 and ((-out_novo_current_balance_cliente) > out_limit_cliente) then
	    	out_status = 'SI'; -- current_balance insuficiente
	    ELSE
		    INSERT INTO transacao (id_cliente, description, kind, amount)
		    VALUES (p_id_cliente, p_description, p_kind, p_amount);

		   	out_status = 'OK';
	    END IF;
   	end if;
    return next;
END;
$$
LANGUAGE plpgsql;

DO $$
BEGIN
    IF NOT EXISTS (SELECT * from cliente) THEN
        INSERT INTO cliente (id, limit, current_balance)
        VALUES
            (1, 100000, 0),
            (2, 80000, 0),
            (3, 1000000, 0),
            (4, 10000000, 0),
            (5, 500000, 0);
    end if;
end; $$
