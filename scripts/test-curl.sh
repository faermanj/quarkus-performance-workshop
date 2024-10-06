curl -v -X POST \
    -H "Content-Type: application/json" \
    -d '{"amount": 10, "kind": "d", "description": "teste"}' \
        http:///localhost:9999/members/333/transactions | jq

curl -v -X GET \
    http://localhost:9999/members/333/balance | jq

