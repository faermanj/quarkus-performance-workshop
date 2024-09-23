var connection = new Mongo();
var database = connection.getDB("database");

database.createCollection("clientes");

database.clientes.insertMany([
    {
      "_id": 1,
      "limite": 100000,
      "saldo": 0,
      "ultimas_transactions": []
    },
    {
      "_id": 2,
      "limite": 80000,
      "saldo": 0,
      "ultimas_transactions": []
    },
    {
      "_id": 3,
      "limite": 1000000,
      "saldo": 0,
      "ultimas_transactions": []
    },
    {
      "_id": 4,
      "limite": 10000000,
      "saldo": 0,
      "ultimas_transactions": []
    },
    {
      "_id": 5,
      "limite": 500000,
      "saldo": 0,
      "ultimas_transactions": []
    }
]);