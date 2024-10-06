// init-mongo.js

db = db.getSiblingDB('rinha');

// Insira seus registros aqui
db.members.insertMany([
  { user_id: "1", limit: 1000 * 100, saldo: 0 },
  { user_id: "2", limit: 800 * 100, saldo: 0 },
  { user_id: "3", limit: 10000 * 100, saldo: 0 },
  { user_id: "4", limit: 100000 * 100, saldo: 0 },
  { user_id: "5", limit: 5000 * 100, saldo: 0 }
]);
