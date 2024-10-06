-- name: GetCustomer :one
SELECT * FROM clientes
WHERE id = $1 LIMIT 1;

-- name: UpdateCustomer :many
UPDATE clientes
  set current_balance = current_balance + $2
WHERE id = $1
RETURNING *;

-- name: InsertTransaction :exec
INSERT INTO transactions (
  cliente_id, amount, kind, description
) VALUES (
  $1, $2, $3, $4
);

-- name: GetLastTransactions :many
SELECT amount, kind, description, submitted_at FROM transactions
WHERE cliente_id = $1 ORDER BY id DESC LIMIT 10;
