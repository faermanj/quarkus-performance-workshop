CREATE TABLE public."members" (
	"Id" int4 NOT NULL GENERATED BY DEFAULT AS IDENTITY,
	"Limite" int4 NOT NULL,
	"Saldo" int4 NOT NULL,
	CONSTRAINT "PK_members" PRIMARY KEY ("Id")
);

CREATE TABLE public."Transacoes" (
	"Id" SERIAL,
	"ClienteId" int4 NOT NULL,
	"Valor" int4 NOT NULL,
	"Tipo" bpchar(1) NOT NULL,
	"Descricao" varchar(10) NOT NULL,
	"Data" timestamptz NOT NULL,
	CONSTRAINT "PK_Transacoes" PRIMARY KEY ("Id")
);
CREATE INDEX "IX_Transacoes_ClienteId" ON public."Transacoes" USING btree ("ClienteId");
ALTER TABLE public."Transacoes" ADD CONSTRAINT "FK_Transacoes_members_ClienteId" FOREIGN KEY ("ClienteId") REFERENCES public."members"("Id") ON DELETE CASCADE;

INSERT INTO public."members" ("Id", "Limite", "Saldo")
VALUES
    (1, 100000, 0),
    (2, 80000, 0),
    (3, 1000000, 0),
    (4, 10000000, 0),
    (5, 500000, 0);

CREATE OR REPLACE FUNCTION atualiza_saldo(p_id INT, p_valor INT, p_tipo BPCHAR(1), p_descricao VARCHAR(10))
RETURNS TABLE (Saldo INT, Erro BOOLEAN) AS $$

DECLARE rows_affected INT;

BEGIN
	UPDATE "members"
	SET "Saldo" =
		(CASE
			WHEN 'd' = p_tipo
				THEN "Saldo" - p_valor
				ELSE "Saldo" + p_valor
		END)
	WHERE
		"Id" = p_id
		AND CASE
			WHEN 'd' = p_tipo
				THEN ("Saldo" - p_valor + "Limite") >= 0
				ELSE TRUE
			END;

	GET DIAGNOSTICS rows_affected = ROW_COUNT;

	IF rows_affected > 0 THEN
		INSERT INTO public."Transacoes"
		("Id", "ClienteId", "Valor", "Tipo", "Descricao", "Data")
		VALUES(DEFAULT, p_id, p_valor, p_tipo, p_descricao, NOW());

		RETURN query
		SELECT "Saldo", FALSE AS "Erro" FROM "members" c WHERE "Id" = p_id;
	ELSE
		RETURN query
		SELECT NULL::INT AS "Saldo", TRUE AS "Erro";
	END IF;
END;
$$ LANGUAGE plpgsql;