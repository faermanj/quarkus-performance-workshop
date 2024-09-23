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
    public int saldo;
    public int limite;
    public int status;
    public PriorityQueue<Transacao> transactions;
    private String nome;

    public static Cliente of(Integer shard, Integer id, String nome, int saldo, int limite, int status, PriorityQueue<Transacao> txxs) {
        var c = new Cliente();
        c.id = id;
        c.saldo = saldo;
        c.limite = limite;
        c.status = status;
        c.nome = "Cliente "+id;
        c.transactions = txxs;
        return c;
    }

    public static int limiteOf(Integer id) {
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
                    "valor": %d,
                    "tipo": "%s",
                    "descricao": "%s",
                    "realizada_em": "%s"
                }""", t.valor, t.tipo, t.descricao, t.realizadaEm));
            if (i < txxs.size() - 1) {
                transactionsJson.append(",");
            }
        }
        transactionsJson.append("]");

        String dataExtrato = ZonedDateTime.now().format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);

        return String.format("""
               {
                 "saldo": {
                   "total": %d,
                   "date_balance": "%s",
                   "limite": %d
                 },
                 "ultimas_transactions": %s
               }
               """, saldo, dataExtrato, limite, transactionsJson);
    }

    public synchronized Cliente transacao(Integer valor, String tipo, String descricao) {
        var diff = switch (tipo) {
            case "d" -> -1 * valor;
            default -> valor;
        };
        var novo = valor + diff;
        if (novo < -1 * limiteOf(id)){
            Log.warn("---- LIMITE ULTRAPASSADO ---");
            return Cliente.error(422);
        }
        var txx = Transacao.of(valor, tipo, descricao, LocalDateTime.now());
        //needed?
        var txxs = new PriorityQueue<>(gettransactions());
        txxs.add(txx);
        if (txxs.size() > 10){
            txxs.poll();
        }
        var nsaldo = saldo + diff;
        var nstatus = 200;
        return Cliente.of(shard,id,nome,nsaldo,limite,nstatus,txxs);
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
                   "saldo": %d,
                   "limite": %d
                 }
               """, saldo, limite);
    }
}

