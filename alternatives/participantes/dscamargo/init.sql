CREATE TABLE IF NOT EXISTS "clientes" (
                                          "id" serial PRIMARY KEY NOT NULL,
                                          "nome" text NOT NULL,
                                          "current_balance" integer DEFAULT 0 NOT NULL,
                                          "limit" integer DEFAULT 0 NOT NULL
);

CREATE INDEX clientes_id_idx ON "clientes" USING HASH(id);

CREATE TABLE IF NOT EXISTS "transactions" (
                                            "id" serial PRIMARY KEY NOT NULL,
                                            "cliente_id" integer NOT NULL ,
                                            "amount" integer NOT NULL,
                                            "kind" char(1) NOT NULL,
                                            "description" varchar(10) NOT NULL,
                                            "realizado_em" timestamp NOT NULL DEFAULT now()
);

CREATE INDEX transactions_id_idx ON "transactions" USING HASH(id);
CREATE INDEX transactions_cliente_id_idx ON "transactions" USING HASH(cliente_id);

create or replace procedure criar_transacao(
    id_cliente INTEGER,
    amount integer,
    kind text,
    description text,
    inout current_balance_atualizado integer default null,
    inout limit_atualizado integer default null
)

    language plpgsql
as $$

begin
    UPDATE clientes
    set current_balance = current_balance + amount
    where id = id_cliente and current_balance + amount >= - limit
    returning current_balance, limit into current_balance_atualizado, limit_atualizado;

    if current_balance_atualizado is null or limit_atualizado is null then return; end if;

    commit;

    INSERT INTO transactions (amount, kind, description, cliente_id)
    VALUES (ABS(amount), kind, description, id_cliente);
end;
$$;

DO $$
    BEGIN
        INSERT INTO clientes (nome, limit)
        VALUES
            ('o barato sai caro', 1000 * 100),
            ('zan corp ltda', 800 * 100),
            ('les cruders', 10000 * 100),
            ('padaria joia de cocaia', 100000 * 100),
            ('kid mais', 5000 * 100);
    END; $$