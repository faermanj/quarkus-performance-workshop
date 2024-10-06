CREATE UNLOGGED TABLE IF NOT EXISTS members (
  id SERIAL PRIMARY KEY,
  limit INTEGER NOT NULL,
  current_balance INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS transactions (
  id SERIAL PRIMARY KEY,
  id_cliente INTEGER NOT NULL,
  amount INTEGER NOT NULL,
  kind CHAR(1) NOT NULL,
  description VARCHAR(10) NOT NULL,
  submitted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

  FOREIGN KEY (id_cliente) REFERENCES members (id)
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM members WHERE id = 1) THEN
    INSERT INTO members (limit, current_balance)
    VALUES
      (100000, 0),
      (80000, 0),
      (1000000, 0),
      (10000000, 0),
      (500000, 0);
  END IF;
END $$;
