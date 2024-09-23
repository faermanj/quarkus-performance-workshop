db = db.getSiblingDB('rinha');
db.members.insertMany([
    {
        _id: 1,
        Saldo: 0,
        Limite: 100000,
        transactions: []
    },
    {
        _id: 2,
        Saldo: 0,
        Limite: 80000,
        transactions: []
    },
    {
        _id: 3,
        Saldo: 0,
        Limite: 1000000,
        transactions: []
    },
    {
        _id: 4,
        Saldo: 0,
        Limite: 10000000,
        transactions: []
    },
    {
        _id: 5,
        Saldo: 0,
        Limite: 500000,
        transactions: []
    }
]);