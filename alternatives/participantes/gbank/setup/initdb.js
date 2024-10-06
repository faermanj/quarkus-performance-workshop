db = connect("mongodb://localhost/gbank");

// drop clientes and transactions collections, if exist
db.clientes.drop();
db.transactions.drop();

// insert 5 default clientes in collection
db.clientes.insertMany([
  { clienteId: 1, limit: 100000, saldo: 0 },
  { clienteId: 2, limit: 80000, saldo: 0 },
  { clienteId: 3, limit: 1000000, saldo: 0 },
  { clienteId: 4, limit: 10000000, saldo: 0 },
  { clienteId: 5, limit: 500000, saldo: 0 },
]);

// create indexes for clientes and transactions collections
db.clientes.createIndex({ clienteId: 1 });
db.transactions.createIndex({ clienteId: 1 });
