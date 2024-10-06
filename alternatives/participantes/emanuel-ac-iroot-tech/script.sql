--
-- Name: clientes; Type: TABLE; Schema: public; Owner: rinha
--

CREATE TABLE public.clientes (
    id smallint NOT NULL,
    limit integer,
    current_balance integer,
    CONSTRAINT current_balance_check CHECK (((limit + current_balance) > 0))
);


ALTER TABLE public.clientes OWNER TO rinha;

--
-- Name: transactions; Type: TABLE; Schema: public; Owner: rinha
--

CREATE TABLE public.transactions (
    clientes_id integer NOT NULL,
    data timestamp with time zone NOT NULL,
    kind character varying(1),
    description text,
    --description character varying(10),
    amount integer,
    CONSTRAINT kind_check CHECK (kind in ('c','d')),
    CONSTRAINT kind_description CHECK (coalesce(description, '') <> ''),
    CONSTRAINT length_description CHECK (char_length(description)<=10)
);


ALTER TABLE public.transactions OWNER TO rinha;

--
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: rinha
--

INSERT INTO public.clientes VALUES (3, 1000000, 0);
INSERT INTO public.clientes VALUES (1, 100000, 0);
INSERT INTO public.clientes VALUES (2, 80000, 0);
INSERT INTO public.clientes VALUES (4, 10000000, 0);
INSERT INTO public.clientes VALUES (5, 500000, 0);


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: rinha
--



--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: rinha
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: rinha
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (clientes_id, data, kind);


--
-- Name: transactions transactions_fkey_clientes_id; Type: FK CONSTRAINT; Schema: public; Owner: rinha
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_fkey_clientes_id FOREIGN KEY (clientes_id) REFERENCES public.clientes(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

