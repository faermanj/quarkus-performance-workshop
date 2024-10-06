var connection = new Mongo();
var database = connection.getDB("database");

database.createCollection("clientes");

database.clientes.insertMany([
    {
      "_id": 1,
      "limit": 100000,
      "saldo": 0,
      "recent_transactions": []
    },
    {
      "_id": 2,
      "limit": 80000,
      "saldo": 0,
      "recent_transactions": []
    },
    {
      "_id": 3,
      "limit": 1000000,
      "saldo": 0,
      "recent_transactions": []
    },
    {
      "_id": 4,
      "limit": 10000000,
      "saldo": 0,
      "recent_transactions": []
    },
    {
      "_id": 5,
      "limit": 500000,
      "saldo": 0,
      "recent_transactions": []
    }
]);