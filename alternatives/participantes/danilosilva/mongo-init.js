db = db.getSiblingDB('Crebito');

db.createCollection('clientes');

db.clientes.insertMany([
    {
        clienteid: 1,
        limit: 100000,
        saldo: 0
    },
    {
        clienteid: 2,
        limit: 80000,
        saldo: 0
    },
    {
        clienteid: 3,
        limit: 1000000,
        saldo: 0
    },
    {
        clienteid: 4,
        limit: 10000000,
        saldo: 0
    },
    {
        clienteid: 5,
        limit: 500000,
        saldo: 0
    },
]);