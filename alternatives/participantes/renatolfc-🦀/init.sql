CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL,
  atualizado_em TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users(limit, current_balance)
VALUES
  (100000, 0),
  (80000, 0),
  (1000000, 0),
  (10000000, 0),
  (500000, 0);
CREATE TYPE kindt AS ENUM ('C', 'D');
CREATE TABLE ledger (
  id INTEGER GENERATED ALWAYS AS IDENTITY,
  id_cliente INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  kind kindt NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
)
PARTITION BY LIST (id_cliente);
CREATE TABLE ledger_1 PARTITION OF ledger FOR VALUES IN (1);
CREATE TABLE ledger_2 PARTITION OF ledger FOR VALUES IN (2);
CREATE TABLE ledger_3 PARTITION OF ledger FOR VALUES IN (3);
CREATE TABLE ledger_4 PARTITION OF ledger FOR VALUES IN (4);
CREATE TABLE ledger_5 PARTITION OF ledger FOR VALUES IN (5);

CREATE INDEX realizada_idx ON ledger(submitted_at DESC, id_cliente);
CREATE PROCEDURE poe(
  idc INTEGER,
  v INTEGER,
  d VARCHAR(10),
  INOUT current_balance_atual INTEGER = NULL,
  INOUT limit_atual INTEGER = NULL
)
LANGUAGE plpgsql AS
$$
BEGIN
  INSERT INTO ledger (
    id_cliente,
    amount,
    kind,
    description
  ) VALUES (idc, v, 'C', d);

  UPDATE users
  SET current_balance = current_balance + v, atualizado_em = CURRENT_TIMESTAMP
    WHERE users.id = idc
    RETURNING current_balance, limit INTO current_balance_atual, limit_atual;
  COMMIT;
END;
$$;

CREATE PROCEDURE tira(
  idc INTEGER,
  v INTEGER,
  d VARCHAR(10),
  INOUT current_balance_atual INTEGER = NULL,
  INOUT limit_atual INTEGER = NULL
)
LANGUAGE plpgsql AS
$$
BEGIN
  SELECT limit, current_balance INTO limit_atual, current_balance_atual
  FROM users
  WHERE id = idc;

  IF current_balance_atual - v >= limit_atual * -1 THEN
    INSERT INTO ledger (
      id_cliente,
      amount,
      kind,
      description
    ) VALUES (idc, v, 'D', d);

    UPDATE users
      SET current_balance = current_balance - v, atualizado_em = CURRENT_TIMESTAMP
      WHERE users.id = idc
      RETURNING current_balance, limit INTO current_balance_atual, limit_atual;
    COMMIT;
  ELSE
    SELECT -1, -1 INTO current_balance_atual, limit_atual;
  END IF;
END;
$$;
