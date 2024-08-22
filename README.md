# The world is in danger...

There is no better way to put it. I'm sorry that we all face this terrible situation, but together I'm confident we can make it through. Let me explain, for the ones that are new here...

When we decided to centrilize *all* transactions, we were confident that modern cloud computing would solve all our performance issues. With secure and centralized control, the world would be a better place. So much that transactional volume grew beyond our wildest imagination. Buffers started to fill. Queues got longer. Some transactions even failed, something unheard in decades.

Now, the system is at the brink of collapse. We estimate that, in only a few hours, we'll be over capacity in all systems. The gridlock may be inevitable. However, if we can improve the latency of the entire system in only a single digit of a percentage, we might just as well deploy and recover. 

In this repository you will find everything you need. Not only all the code, containers and data but also several variations and experiments from the ones that came before you. The system interface is very simple, taking a json data representing each transaction and keeping up balances. 

Here's a sample transaction:
```
POST /clientes/[id]/transacoes

{
    "valor": 1000,
    "tipo" : "c",
    "descricao" : "descricao"
}

```

And a balance request:
```
GET /clientes/[id]/extrato

{
  "saldo": {
    "total": -9098,
    "data_extrato": "2024-01-17T02:34:41.217753Z",
    "limite": 100000
  },
  "ultimas_transacoes": [
    {
      "valor": 10,
      "tipo": "c",
      "descricao": "descricao",
      "realizada_em": "2024-01-17T02:34:38.543030Z"
    },
    {
      "valor": 90000,
      "tipo": "d",
      "descricao": "descricao",
      "realizada_em": "2024-01-17T02:34:38.543030Z"
    }
  ]
}
```

Please don't worry about other transaction types or the language in the URLs. If we can crack this, we already have a good chance of success.
To avoid unnecessary expenses, we are using only two API instances and limited resources for the entire model architecture (1.5 CPU units and 550MB of memory). If we can make it with such restrictions, I'm confident we would scale to the current volume of transactions.

When you have any improvements, do not hesitate to send a PR.*

Good luck and may fortune bless us all.

