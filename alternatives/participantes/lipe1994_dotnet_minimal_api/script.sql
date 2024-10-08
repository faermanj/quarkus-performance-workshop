CREATE TABLE Cliente (
    Id smallint GENERATED BY DEFAULT AS IDENTITY,
    Total integer NOT NULL,
    Limite integer NOT NULL,
    CONSTRAINT "PK_Cliente" PRIMARY KEY (Id)
);

CREATE TABLE Transacao (
    Id integer GENERATED BY DEFAULT AS IDENTITY,
    Valor integer NOT NULL,
    Descricao character varying(10) NOT NULL,
    Tipo character(1) NOT NULL,
    CriadoEm timestamp with time zone NOT NULL,
    ClienteId smallint NOT NULL,
    CONSTRAINT "PK_Transacao" PRIMARY KEY (Id),
    CONSTRAINT "FK_Transacao_Cliente_ClienteId" FOREIGN KEY (ClienteId) REFERENCES Cliente (Id) ON DELETE CASCADE
);

CREATE INDEX "IX_Transacao_ClienteId" ON Transacao (ClienteId);


INSERT INTO public.Cliente (Id, Total, Limite)
VALUES (1, 0, 100000);

INSERT INTO public.Cliente (Id, Total, Limite)
VALUES (2, 0, 80000);

INSERT INTO public.Cliente (Id, Total, Limite)
VALUES (3, 0, 1000000);

INSERT INTO public.Cliente (Id, Total, Limite)
VALUES (4, 0, 10000000);

INSERT INTO public.Cliente (Id, Total, Limite)
VALUES (5, 0, 500000);



-- Functions
CREATE OR REPLACE FUNCTION creditar(
	ClienteId int4,
	Valor INT,
	Descricao varchar(10)
)
	RETURNS TABLE(
	    LinhaAfetada BOOLEAN,
	    _limit INT,
	    _total INT
	)
	LANGUAGE plpgsql AS
$func$
DECLARE
    updated_limit INT;
    updated_saldo INT;
BEGIN

    UPDATE public.Cliente SET Total = Total + Valor WHERE Id = ClienteId
		RETURNING Limite, Total INTO updated_limit, updated_saldo;

    INSERT INTO public.Transacao (ClienteId, Valor, Descricao, Tipo, CriadoEm) VALUES (ClienteId, Valor, Descricao, 'c', NOW());
    RETURN QUERY SELECT true, updated_limit, updated_saldo;

END;
$func$;

CREATE OR REPLACE FUNCTION debitar(
	ClienteId int4,
	Valor INT,
	Descricao varchar(10)
)
	RETURNS TABLE(
	    LinhaAfetada BOOLEAN,
	    _limit INT,
	    _total INT
	)
	LANGUAGE plpgsql AS
$func$
DECLARE
    updated_limit INT;
    updated_saldo INT;
BEGIN

    update public.Cliente SET Total = Total - @Valor WHERE Id = @ClienteId AND ((Total - @Valor) >= -Limite)
		RETURNING Limite, Total INTO updated_limit, updated_saldo;

    IF FOUND THEN
    	INSERT INTO public.Transacao (ClienteId, Valor, Descricao, Tipo, CriadoEm) VALUES (ClienteId, Valor, Descricao, 'd', NOW());
        RETURN QUERY SELECT true, updated_limit, updated_saldo;
    ELSE
        RETURN QUERY SELECT false, 0, 0;
    END IF;
END;
$func$;