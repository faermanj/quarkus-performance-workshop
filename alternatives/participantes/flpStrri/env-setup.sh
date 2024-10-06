curl -f --silent --request POST --header 'Content-Type: application/json' --data '{"id":1,"limit":100000}' api-1:3000/clientes
curl -f --silent --request POST --header 'Content-Type: application/json' --data '{"id":2,"limit":80000}' api-2:3000/clientes
curl -f --silent --request POST --header 'Content-Type: application/json' --data '{"id":3,"limit":1000000}' api-1:3000/clientes
curl -f --silent --request POST --header 'Content-Type: application/json' --data '{"id":4,"limit":10000000}' api-2:3000/clientes
curl -f --silent --request POST --header 'Content-Type: application/json' --data '{"id":5,"limit":500000}' api-1:3000/clientes
