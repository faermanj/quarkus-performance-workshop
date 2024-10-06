CREATE VIEW v_checa_current_balance_cliente AS
SELECT 
    c.id,
    c.nome,
    c.limit,
    s.amount AS current_balance_atual,
    (COALESCE(amount_credito, 0) - COALESCE(amount_debito, 0)) AS current_balance_calculado,
    s.amount - (COALESCE(amount_credito, 0) - COALESCE(amount_debito, 0)) AS dif_current_balance,
    COALESCE(tot_c, 0) AS tot_transacao_c,
    COALESCE(tot_d, 0) AS tot_transacao_d
FROM
    public.cliente c
JOIN
    public.current_balancecliente s ON c.id = s.cliente_id
LEFT JOIN (
    SELECT 
        cliente_id,
        COUNT(1) AS tot_c,
        SUM(amount) AS amount_credito
    FROM 
        public.transacao
    WHERE 
        kind = 'c'
    GROUP BY 
        cliente_id
) AS total_credito ON c.id = total_credito.cliente_id
LEFT JOIN (
    SELECT 
        cliente_id,
        COUNT(1) AS tot_d,
        SUM(amount) AS amount_debito
    FROM 
        public.transacao
    WHERE 
        kind = 'd'
    GROUP BY 
        cliente_id
) AS total_debito ON c.id = total_debito.cliente_id
ORDER BY 
    c.id;

