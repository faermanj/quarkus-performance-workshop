SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

CREATE TABLE public."Clientes" (
    "Id" integer NOT NULL,
    "Limite" integer NOT NULL,
    "SaldoInicial" integer NOT NULL
);

ALTER TABLE public."Clientes" OWNER TO postgres;

ALTER TABLE public."Clientes" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."Clientes_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE public."transactions" (
    "Id" integer NOT NULL,
    "Valor" integer NOT NULL,
    "ClienteId" integer NOT NULL,
    "Tipo" varchar(1) NOT NULL,
    "Descricao" text NOT NULL,
    "RealizadoEm" timestamp DEFAULT NOW()
);

ALTER TABLE public."transactions" OWNER TO postgres;

ALTER TABLE public."transactions" ALTER COLUMN "Id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."transactions_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

COPY public."Clientes" ("Id", "Limite", "SaldoInicial") FROM stdin;
1	100000	0
2	80000	0
3	1000000	0
4	10000000	0
5	500000	0
\.

COPY public."transactions" ("Id", "Valor", "ClienteId", "Tipo", "Descricao", "RealizadoEm") FROM stdin;
\.

SELECT pg_catalog.setval('public."Clientes_Id_seq"', 1, false);

SELECT pg_catalog.setval('public."transactions_Id_seq"', 1, false);

ALTER TABLE ONLY public."Clientes"
    ADD CONSTRAINT "PK_Clientes" PRIMARY KEY ("Id");

ALTER TABLE ONLY public."transactions"
    ADD CONSTRAINT "PK_transactions" PRIMARY KEY ("Id");

CREATE INDEX "IX_transactions_ClienteId" ON public."transactions" USING btree ("ClienteId");

ALTER TABLE ONLY public."transactions"
    ADD CONSTRAINT "FK_transactions_Clientes_ClienteId" FOREIGN KEY ("ClienteId") REFERENCES public."Clientes"("Id") ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION public.GetSaldoClienteById(IN id INTEGER)
RETURNS TABLE (
    Total INTEGER,
    Limite INTEGER,
    date_balance TIMESTAMP,
    transactions JSON
) AS $$
BEGIN
  RETURN QUERY 
  SELECT c."SaldoInicial" AS Total, 
	     c."Limite" AS Limite, 
	     NOW()::timestamp AS date_balance,
	     COALESCE(json_agg(t) FILTER (WHERE t."ClienteId" IS NOT NULL), '[]') AS transactions
  FROM public."Clientes" c
  LEFT JOIN (
    SELECT "ClienteId", "Valor", "Tipo", "Descricao", "RealizadoEm"
    FROM public."transactions"
    WHERE "ClienteId" = $1
    ORDER BY "Id" DESC
    LIMIT 10
  ) t ON (c."Id" = t."ClienteId")
  WHERE "Id" = $1
  GROUP BY 
    c."SaldoInicial", c."Limite";
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.InsertTransacao(IN id INTEGER, IN amount INTEGER, IN kind VARCHAR(1), IN description VARCHAR(10))
RETURNS INTEGER AS $$
BEGIN
  INSERT INTO public."transactions" ("Valor", "Tipo", "Descricao", "ClienteId", "RealizadoEm")
  VALUES ($2, $3, $4, $1, NOW());

  UPDATE public."Clientes"
  SET "SaldoInicial" = "SaldoInicial" + ($2 * CASE WHEN $3 = 'c' THEN 1 ELSE -1 END)
  WHERE "Id" = $1
  AND ("SaldoInicial" + ($2 * CASE WHEN $3 = 'c' THEN 1 ELSE -1 END) >= "Limite" * -1 OR $2 * CASE WHEN $3 = 'c' THEN 1 ELSE -1 END > 0);
 
  RETURN (SELECT "SaldoInicial" FROM public."Clientes" WHERE "Id" = $1);
END;
$$ LANGUAGE plpgsql;