CREATE TABLE IF NOT EXISTS members (
			id SERIAL PRIMARY KEY,
			limit INT,
			current_balance INT DEFAULT 0
		);

CREATE TABLE IF NOT EXISTS transactions (
			id SERIAL PRIMARY KEY,
			amount INT,
			kind CHAR(1),
			description VARCHAR(10),
			submitted_at TIMESTAMP,
			id_cliente INT
		);

DO $$
BEGIN
  IF NOT EXISTS (SELECT * FROM members WHERE id BETWEEN 1 AND 5) THEN
    INSERT INTO members (limit) 
			VALUES 
			(1000 * 100),
			(800 * 100),
			(10000 * 100),
			(100000 * 100),
			(5000 * 100);
  END IF;
END;
$$;