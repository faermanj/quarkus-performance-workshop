--
-- PostgreSQL database dump
--

-- Dumped from database version 15.5 (Debian 15.5-1.pgdg120+1)
-- Dumped by pg_dump version 15.5

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA IF NOT EXISTS public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dados_bancarios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dados_bancarios (
    id_conta integer NOT NULL,
    limit bigint NOT NULL,
    nome_cliente text NOT NULL
);


ALTER TABLE public.dados_bancarios OWNER TO postgres;

--
-- Name: current_balances; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.current_balances (
    id_conta integer NOT NULL,
    current_balance bigint NOT NULL
);


ALTER TABLE public.current_balances OWNER TO postgres;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    id bigint NOT NULL,
    id_conta integer NOT NULL,
    kind_operacao "char" NOT NULL,
    amount bigint NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transactions_id_seq OWNER TO postgres;

--
-- Name: transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;


--
-- Name: transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);


--
-- Data for Name: dados_bancarios; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dados_bancarios VALUES (1, 100000, 'o barato sai caro');
INSERT INTO public.dados_bancarios VALUES (2, 80000, 'zan corp ltda');
INSERT INTO public.dados_bancarios VALUES (3, 1000000, 'les cruders');
INSERT INTO public.dados_bancarios VALUES (4, 10000000, 'padaria joia de cocaia');
INSERT INTO public.dados_bancarios VALUES (5, 500000, 'kid mais');


--
-- Data for Name: current_balances; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.current_balances VALUES (1, 0);
INSERT INTO public.current_balances VALUES (2, 0);
INSERT INTO public.current_balances VALUES (3, 0);
INSERT INTO public.current_balances VALUES (4, 0);
INSERT INTO public.current_balances VALUES (5, 0);



--
-- Name: dados_bancarios dados_bancarios_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dados_bancarios
    ADD CONSTRAINT dados_bancarios_pkey PRIMARY KEY (id_conta);


--
-- Name: transactions operacao; Type: CHECK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE public.transactions
    ADD CONSTRAINT operacao CHECK (((kind_operacao = 'c'::"char") OR (kind_operacao = 'd'::"char"))) NOT VALID;


--
-- Name: current_balances current_balances_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_balances
    ADD CONSTRAINT current_balances_pkey PRIMARY KEY (id_conta);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: transactions id_conta; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT id_conta FOREIGN KEY (id_conta) REFERENCES public.dados_bancarios(id_conta) ON UPDATE RESTRICT ON DELETE RESTRICT NOT VALID;


--
-- Name: current_balances current_balances_contas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.current_balances
    ADD CONSTRAINT current_balances_contas FOREIGN KEY (id_conta) REFERENCES public.dados_bancarios(id_conta) NOT VALID;


--
-- PostgreSQL database dump complete
--

