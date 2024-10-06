package caravanacloud.ispn;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Comparator;


public class Transacao implements Serializable{
    public int amount;
    public String kind;
    public String description;
    public LocalDateTime realizadaEm;

    public LocalDateTime getRealizadaEm() {
        return realizadaEm;
    }


    public static final TransacaoComparator comparator = new TransacaoComparator();
    

    public static Transacao of(int amount2, String kind2, String description2, LocalDateTime realizadaEm) {
        var t = new Transacao();
        t.amount = amount2;
        t.kind = kind2;
        t.description = description2;
        t.realizadaEm = realizadaEm;
        return t;
    }
}
