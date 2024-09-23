CREATE TABLE members (
    id INT PRIMARY KEY,
    limite BIGINT NOT NULL,
    saldo BIGINT NOT NULL DEFAULT '0'
    -- TODO ver se o INTEGER e suficiente
);

CREATE TYPE tipo_transacao AS ENUM ('c', 'd');
CREATE TABLE transactions(
    id SERIAL PRIMARY KEY, -- TODO ver se precisa disso
    valor BIGINT NOT NULL,
    tipo tipo_transacao NOT NULL,
    descricao VARCHAR(10) NOT NULL,
    realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
    cliente_id INT NOT NULL REFERENCES members(id)
);

INSERT INTO members VALUES
('1', '100000', '0'),
('2', '80000', '0'),
('3', '1000000', '0'),
('4', '10000000', '0'),
('5', '500000', '0');

CREATE OR REPLACE PROCEDURE insert_transacao(
  pvalor BIGINT,
  ptipo tipo_transacao,
  pdescricao VARCHAR(10),
  pcliente_id INTEGER,
  
  INOUT v_saldo BIGINT DEFAULT NULL,
  INOUT v_limite BIGINT DEFAULT NULL,
  INOUT v_status SMALLINT DEFAULT 0
  -- 0 => OK
  -- 404 => OK
  -- 422 => OK
)
LANGUAGE plpgsql
AS $$
DECLARE
    vcliente_id INTEGER := NULL;
BEGIN
    SELECT id FROM members
    INTO vcliente_id
    WHERE id = pcliente_id
    FOR UPDATE;

    if vcliente_id is NULL then
        v_status := 404;
        return;
    end if;

    if ptipo = 'c' then
          UPDATE members
          SET saldo = saldo + pvalor
          WHERE id = pcliente_id
          RETURNING saldo, limite INTO v_saldo, v_limite;
    elsif ptipo = 'd' then
          UPDATE members
          SET saldo = saldo - pvalor
          WHERE id = pcliente_id AND saldo - pvalor >= -limite
          RETURNING saldo, limite INTO v_saldo, v_limite;
          if v_saldo is null then
              v_status := 422;
              return;
          end if;
    end if;
    INSERT INTO transactions
    (valor, tipo, descricao, cliente_id)
    VALUES
    (pvalor, ptipo, pdescricao, pcliente_id);
END;
$$;


CREATE OR REPLACE PROCEDURE balance(
  cid INTEGER,
  INOUT cliente refcursor,
  INOUT transactions refcursor
)
LANGUAGE plpgsql
AS $$
BEGIN
    OPEN cliente FOR
    SELECT id, limite, saldo AS total FROM members
    WHERE id = cid;

    OPEN transactions FOR
    SELECT valor, tipo, descricao, realizada_em FROM transactions
    WHERE cliente_id = cid
    ORDER BY id DESC
    LIMIT 10;
END;
$$;

CREATE INDEX IF NOT EXISTS saldo_index ON members(saldo);
CREATE INDEX IF NOT EXISTS id_trc ON transactions(id DESC);
CREATE INDEX IF NOT EXISTS cid_transactions ON transactions(cliente_id);

