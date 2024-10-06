db = connect('mongodb://localhost/rinha')

db.clients.insertMany([
    {
        id: 1,
        limit: 100000,
        saldo_inicial: 0
    },
    {
        id: 2,
        limit: 80000,
        saldo_inicial: 0
    },
    {
        id: 3,
        limit: 1000000,
        saldo_inicial: 0
    },
    {
        id: 4,
        limit: 10000000,
        saldo_inicial: 0
    },
    {
        id: 5,
        limit: 500000,
        saldo_inicial: 0
    },
])