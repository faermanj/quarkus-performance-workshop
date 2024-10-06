db = db.getSiblingDB('admin');

db.createCollection('clientes');
db.createCollection('transactions');

db.clientes.insertMany([
 {
    _id: 1,
    nome: 'o barato sai caro',
    limit: 100000,
    saldo: 0
  },
  {
    _id: 2,
    nome: 'zan corp ltda',
    limit: 80000,
    saldo: 0
  },
  {
    _id: 3,
    nome: 'les cruders',
    limit: 1000000,
    saldo: 0
  },
  {
    _id: 4,
    nome: 'padaria joia de cocaia',
    limit: 10000000,
    saldo: 0
  },
  {
    _id: 5,
    nome: 'kid mais',
    limit: 500000,
    saldo: 0
  },
]);