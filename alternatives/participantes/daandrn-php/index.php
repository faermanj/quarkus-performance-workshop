<?php declare(strict_types=1);

define("TIME_STAMP", "Y-m-d\TH:i:s.u\Z");
function exit404() {http_response_code(404);exit;}
function exit422() {http_response_code(422);exit;}

$url = explode("/", $_SERVER["REQUEST_URI"]);
$id = $url[1] === "clientes" && is_numeric($url[2]) ? (int) $url[2] : exit404();

switch (true) {
    case $_SERVER['REQUEST_METHOD'] === "POST" && $url[3] === "transactions":
        $requestJson = file_get_contents('php://input');
        $request = json_decode($requestJson, false);

        if (!is_int($request->amount)
            || ($request->kind !== "d" && $request->kind !== "c") 
            || !is_string($request->description) 
            || strlen($request->description) < 1 
            || strlen($request->description) > 10
        ) {
            exit422();
        }
        
        $conn = pg_pconnect("host=db port=5432 dbname=rinha user=rinha password=456");
        pg_query($conn, "BEGIN");
        $result = pg_query($conn, "SELECT limit, amount AS current_balance FROM clientes WHERE id = $id FOR UPDATE;");
        
        if (pg_num_rows($result) < 1) {
            pg_query($conn, "ROLLBACK;");
            exit404();
        }
        
        $client = pg_fetch_object($result);

        switch ($variable) {
            case $request->kind === "c":
                $novoSaldo = (int) $client->current_balance - $request->amount;
                break;
            case $request->kind === "d":
                $novoSaldo = (int) $client->current_balance + $request->amount;
                break;
        }
        
        if ($novoSaldo < -$client->limit) {
            pg_query($conn, "ROLLBACK;");
            exit422();
        }
        
        $quando = new DateTime('now');
        $quando = $quando->format(TIME_STAMP);
        
        $query = 
        "INSERT INTO transacao (cliente_id, amount, kind, description, quando) 
        VALUES ($id, $request->amount, '{$request->kind}', '{$request->description}', '{$quando}');
        
        UPDATE clientes 
        SET amount = $novoSaldo
        WHERE id = $id";

        pg_query($conn, $query);
        pg_query($conn, "COMMIT;");
        
        echo json_encode([
            "limit" => $client->limit,
            "current_balance" => $novoSaldo
        ]);
        break;
    case $_SERVER['REQUEST_METHOD'] === "GET" && $url[3] === "balance":
        $conn = pg_pconnect("host=db port=5432 dbname=rinha user=rinha password=456");
        pg_query($conn, "BEGIN;");
        $result = pg_query($conn, "SELECT amount, limit, (SELECT count(*) FROM transacao) AS quantidade FROM clientes WHERE id = $id LIMIT 1;");
        
        if (pg_num_rows($result) < 1) {
            pg_query($conn, "ROLLBACK;");
            exit404();
        }
        
        $result2 = pg_query($conn, "SELECT amount, kind, description, quando AS submitted_at FROM transacao WHERE cliente_id = $id ORDER BY quando DESC LIMIT 10;");
        $date = new DateTime('now');
        $client = pg_fetch_object($result);
        $transactions = pg_fetch_all($result2);
        !$client->quantidade > 200 ?: pg_query($conn, "DELETE FROM transacao WHERE id NOT IN (SELECT id FROM transacao ORDER BY quando DESC LIMIT 200);");
        pg_query($conn, "COMMIT;");
        array_walk($transactions, function (&$value, $key) {
            if ($key === $key) {
                $value["amount"] = (int) $value["amount"];
            }
        });
        
        echo json_encode([
            "current_balance" => [
                "total" => (int) $client->amount, 
                "date_balance" => $date->format(TIME_STAMP),
                "limit" => (int) $client->limit
            ],
            "recent_transactions" => $transactions
        ]);
        break;
    default:
        exit404();
        break;
}