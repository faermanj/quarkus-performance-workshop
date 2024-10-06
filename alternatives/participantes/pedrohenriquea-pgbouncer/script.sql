CREATE TABLE cliente (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(50) NOT NULL,
	limit INTEGER NOT NULL,
	saldo INTEGER NOT NULL,
	recent_transactions json
);

DO $$
BEGIN
        INSERT INTO cliente (nome, limit, saldo, recent_transactions)
		VALUES
			('o barato sai caro', 1000 * 100, 0, '[]'),
			('zan corp ltda', 800 * 100, 0, '[]'),
			('les cruders', 10000 * 100, 0, '[]'),
			('padaria joia de cocaia', 100000 * 100, 0, '[]'),
			('kid mais', 5000 * 100, 0, '[]');
END;
$$;