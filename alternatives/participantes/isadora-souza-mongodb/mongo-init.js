db = connect("mongodb://localhost/rinhabackenddb");

db.clientes.insertMany([
  {
    id: 1,
    limit: 100000,
    saldo: 0,
    disponivel: 100000,
    recent_transactions: [],
  },
  {
    id: 2,
    limit: 80000,
    saldo: 0,
    disponivel: 80000,
    recent_transactions: [],
  },
  {
    id: 3,
    limit: 1000000,
    saldo: 0,
    disponivel: 1000000,
    recent_transactions: [],
  },
  {
    id: 4,
    limit: 10000000,
    saldo: 0,
    disponivel: 10000000,
    recent_transactions: [],
  },
  {
    id: 5,
    limit: 500000,
    saldo: 0,
    disponivel: 500000,
    recent_transactions: [],
  },
]);
