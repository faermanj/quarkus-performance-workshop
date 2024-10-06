CREATE TABLE transacao (
    id SERIAL PRIMARY KEY,
    amount integer NOT NULL,
    kind CHAR(1) not null,
    description varchar(10) NOT NULL,
    submitted_at timestamp NOT NULL DEFAULT (NOW() at time zone 'utc'),
    cliente_id integer NOT NULL
);

CREATE TABLE current_balances (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT null unique,
	limit INTEGER NOT NULL,
	amount INTEGER NOT NULL
);

INSERT INTO current_balances (cliente_id, limit, amount)
VALUES (1,   1000 * 100, 0),
	   (2,    800 * 100, 0),
	   (3,  10000 * 100, 0),
	   (4, 100000 * 100, 0),
	   (5,   5000 * 100, 0);