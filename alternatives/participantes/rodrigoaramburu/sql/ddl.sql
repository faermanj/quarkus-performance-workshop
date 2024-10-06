CREATE TABLE IF NOT EXISTS public.members
(
    id SERIAL NOT NULL,
    nome character varying(100) NOT NULL DEFAULT 0,
    limit integer NOT NULL DEFAULT 0,
    current_balance integer NOT NULL DEFAULT 0,
    CONSTRAINT members_pkey PRIMARY KEY (id)
);


CREATE TABLE IF NOT EXISTS public.transactions
(
    id SERIAL NOT NULL,
    amount integer NOT NULL DEFAULT 0,
    kind char NOT NULL DEFAULT 0,
    description character varying(100) NOT NULL DEFAULT '',
    submitted_at TIMESTAMP WITH TIME ZONE NOT NULL,
    cliente_id integer NOT NULL,
    CONSTRAINT transactions_pkey PRIMARY KEY (id),
    CONSTRAINT transactions_cliente_id_fkey FOREIGN KEY (cliente_id)
        REFERENCES public.members (id)
);