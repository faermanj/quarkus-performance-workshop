conn = new Mongo();
db = conn.getDB("rinha");

db.clientes.createIndex({ id: 1 }, { unique: true });

db.clientes.insert({ saldo: 0, limit: 1000 * 100, id: 1 });
db.clientes.insert({ saldo: 0, limit: 800 * 100, id: 2 });
db.clientes.insert({ saldo: 0, limit: 10000 * 100, id: 3 });
db.clientes.insert({ saldo: 0, limit: 100000 * 100, id: 4 });
db.clientes.insert({ saldo: 0, limit: 5000 * 100, id: 5 });
