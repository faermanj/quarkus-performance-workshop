package caravanacloud.ispn;

import io.quarkus.logging.Log;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.Iterator;
import java.util.PriorityQueue;



public class Cliente implements Serializable {
    public Integer shard;
    public Integer id;
    public int current_balance;
    public int limit;
    public int status;
    public PriorityQueue<Transacao> transactions;
    private String nome;

    public static Cliente of(Integer shard, Integer id, String nome, int current_balance, int limit, int status, PriorityQueue<Transacao> txxs) {
        var c = new Cliente();
        c.id = id;
        c.current_balance = current_balance;
        c.limit = limit;
        c.status = status;
        c.nome = "Cliente "+id;
        c.transactions = txxs;
        return c;
    }

    public static int limitOf(Integer id) {
        return switch (id){
            case 1 -> 100000;
            case 2 -> 80000;
            case 3 -> 1000000;
            case 4 -> 10000000;
            case 5 -> 500000;
            default -> -1;
        };
    }

    public String toExtrato(){
        var txxs = gettransactions();
        StringBuilder transactionsJson = new StringBuilder("[");
        Iterator itx = txxs.iterator();
        for (int i = 0; itx.hasNext(); i++) {
            Transacao t = (Transacao) itx.next();
            transactionsJson.append(String.format("""
                {
                    "amount": %d,
                    "kind": "%s",
                    "description": "%s",
                    "submitted_at": "%s"
                }""", t.amount, t.kind, t.description, t.realizadaEm));
            if (i < txxs.size() - 1) {
                transactionsJson.append(",");
            }
        }
        transactionsJson.append("]");

        String dataExtrato = ZonedDateTime.now().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);

        return String.format("""
               {
                 "current_balance": {
                   "total": %d,
                   "date_balance": "%s",
                   "limit": %d
                 },
                 "recent_transactions": %s
               }
               """, current_balance, dataExtrato, limit, transactionsJson);
    }

    public synchronized Cliente transacao(Integer amount, String kind, String description) {
        var diff = switch (kind) {
            case "d" -> -1 * amount;
            default -> amount;
        };
        var novo = amount + diff;
        if (novo < -1 * limitOf(id)){
            Log.warn("---- LIMITE ULTRAPASSADO ---");
            return Cliente.error(422);
        }
        var txx = Transacao.of(amount, kind, description, LocalDateTime.now());
        //needed?
        var txxs = new PriorityQueue<>(gettransactions());
        txxs.add(txx);
        if (txxs.size() > 10){
            txxs.poll();
        }
        var ncurrent_balance = current_balance + diff;
        var nstatus = 200;
        return Cliente.of(shard,id,nome,ncurrent_balance,limit,nstatus,txxs);
    }

    private static Cliente error(int status) {
        var cliente = new Cliente();
        cliente.status = status;
        return cliente;
    }

    private synchronized  PriorityQueue<Transacao> gettransactions() {
        if (transactions == null){
            
            transactions = new PriorityQueue<>(Transacao.comparator);
        }
        return transactions;
    }

    public String toTransacao() {
        return String.format("""
                {
                   "current_balance": %d,
                   "limit": %d
                 }
               """, current_balance, limit);
    }
}

