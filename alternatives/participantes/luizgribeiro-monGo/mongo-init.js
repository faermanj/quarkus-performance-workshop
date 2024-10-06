conn = new Mongo();
db = conn.getDB("rinha");

db.accounts.drop();

db.accounts.insertMany(
  [
    {
      "_id": 1,
      "saldo": {
        "total": 0,
        "limit": 100000
      },
      "recent_transactions": [],
      "gordurinha": 100000
    },
    {
      "_id": 2,
      "saldo": {
        "total": 0,
        "limit": 80000
      },
      "recent_transactions": [],
      "gordurinha": 80000
    },
    {
      "_id": 3,
      "saldo": {
        "total": 0,
        "limit": 1000000
      },
      "recent_transactions": [],
      "gordurinha": 1000000
    },
    {
      "_id": 4,
      "saldo": {
        "total": 0,
        "limit": 10000000
      },
      "recent_transactions": [],
      "gordurinha": 10000000
    },
    {
      "_id": 5,
      "saldo": {
        "total": 0,
        "limit": 500000
      },
      "recent_transactions": [],
      "gordurinha": 500000
    }

  ]
);
