db = db.getSiblingDB('rinha2024q1');

db.createCollection("transacao", { capped : true, size: 102400, max :100 } );

db.createCollection('cliente');

db.cliente.insert({ _id: 1, saldo: 0 , limit: 100000});

db.cliente.insert({ _id: 2, saldo: 0, limit: 80000 });

db.cliente.insert({ _id: 3, saldo: 0, limit: 1000000 });

db.cliente.insert({ _id: 4, saldo: 0, limit: 10000000 });

db.cliente.insert({ _id: 5, saldo: 0, limit: 500000 });
