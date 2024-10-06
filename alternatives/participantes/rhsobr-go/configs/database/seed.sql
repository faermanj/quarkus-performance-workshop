INSERT INTO
    members (id, limit)
VALUES
    (1, 1000 * 100),
    (2, 800 * 100),
    (3, 10000 * 100),
    (4, 100000 * 100),
    (5, 5000 * 100);

CREATE EXTENSION IF NOT EXISTS pg_prewarm;

SELECT
    pg_prewarm('members');

SELECT
    pg_prewarm('transactions');