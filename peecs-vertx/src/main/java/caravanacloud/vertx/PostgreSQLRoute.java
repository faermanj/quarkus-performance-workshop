package caravanacloud.vertx;

import java.time.Duration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.quarkus.logging.Log;
import io.quarkus.runtime.StartupEvent;
import io.smallrye.mutiny.Uni;
import io.vertx.mutiny.core.Vertx;
import io.vertx.mutiny.pgclient.PgPool;
import io.vertx.mutiny.sqlclient.Row;
import io.vertx.mutiny.sqlclient.RowSet;
import io.vertx.mutiny.sqlclient.Tuple;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.Response;

@ApplicationScoped
@Path("/members")
public class PostgreSQLRoute {
    private static final String VERSION_ID = "Devoxx 2024 - rc4";
    private static final String EXTRATO_QUERY = "select status_code, body from proc_balance($1)";
    private static final String TRANSACAO_QUERY = "select status_code, body from proc_transacao($1, $2, $3, $4)";
    private static final String WARMUP_QUERY = "select 1+1;";
    private static final int WARMUP_LEVEL = 10;
    private static final Uni<Response> ERR_404 = Uni.createFrom().item(Response.status(404).build());
    private static final Response RES_422 = Response.status(422).build();
    private static final Uni<Response> ERR_422 = Uni.createFrom().item(RES_422);
    private static final String amountPattern = "\"amount\":\\s*(\\d+(\\.\\d+)?)";
    private static final String kindPattern = "\"kind\":\\s*\"([^\"]*)\"";
    private static final String descriptionPattern = "\"description\":\\s*(?:\"([^\"]*)\"|null)";

    private static final Pattern pValor = Pattern.compile(amountPattern);
    private static final Pattern pTipo = Pattern.compile(kindPattern);
    private static final Pattern pDescricao = Pattern.compile(descriptionPattern);
    
    @Inject
    Vertx vertx;

    @Inject
    PgPool client;

    public void onStartup(@Observes StartupEvent event) {
        Log.infof("StartupEvent [" + VERSION_ID + "]");
        boolean ready = false;
        do {
            try {
                for (int i = 0; i < WARMUP_LEVEL; i++) {
                    warmup();
                    processExtrato(333);
                    processTransacao(333,  "{\"amount\":\"0\",\"kind\":\"c\",\"description\":\"warmup\"}");
                }
                ready = true;
            } catch (Exception e) {
                System.err.println("Warmup failed, waiting for db: " + e.getMessage());
                ready = false;
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException ie) {
                    ie.printStackTrace();
                }
            }
        } while (!ready);
    }

    private void warmup() {
        var query = getEnv("RINHA_WARMUP_QUERY", WARMUP_QUERY);
        Log.debug("Warmup query: " + query);
        client.preparedQuery(query)
                .execute()
                .await()
                .atMost(Duration.ofSeconds(30));
        Log.debug("Warmup done");
    }

    private boolean invalid(int id) {
        return ! (id == 1 || id == 2 || id == 3 || id == 4 || id == 5 || id == 333);
    }

    @GET
    @Path("/{id}/balance")
    public Uni<Response> doGet(@PathParam("id") int id) {
        if (invalid(id)) {
            return ERR_404;
        }
        return processExtrato(id)
            .onItem().transform(r -> r != null ? r : RES_422);
    }

    private Uni<Response> processExtrato(int id) {
        return client.preparedQuery(EXTRATO_QUERY)
                .execute(Tuple.of(id))
                .onItem().transform(RowSet::iterator) 
                .onItem().transform(iterator -> iterator.hasNext() ? responseOf(iterator.next()) : null)
                .onFailure().recoverWithItem(e -> errorOf(e,"err_balance")); 
    }

    @Path("/{id}/transactions")
    @Consumes("application/json")
    @Produces("application/json")  
    @POST
    public Uni<Response> doPost(@PathParam("id") int id, String txs) {
        if (invalid(id)) {
            return ERR_404;
        }
        var result = processTransacao(id, txs);
        var resp = result.onItem().transform(r -> r != null ? r : RES_422);
        return resp;
    }

    private Uni<Response> processTransacao(int id, String txs) {
        Matcher mValor = pValor.matcher(txs);
        Matcher mTipo = pTipo.matcher(txs);
        Matcher mDescricao = pDescricao.matcher(txs);

        if (! (mValor.find() && mTipo.find() && mDescricao.find())){
            return ERR_422;
        }
            
        // Os amountes foram extraídos com sucesso
        String amountNumber = mValor.group(1);
        String kind = mTipo.group(1);
        String description = mDescricao.group(1);

        if (amountNumber == null || amountNumber.contains(".")) {
            return ERR_422;
        }

        int amount = -1;
        try {
            amount = Integer.parseInt(amountNumber);
        } catch (NumberFormatException e) {
            return ERR_422;
        }
        final int amountFinal = amount;

        if (kind == null || !("c".equals(kind) || "d".equals(kind))) {
            return ERR_422;
        }

        if (description == null || description.isEmpty() || description.length() > 10 || "null".equals(description)) {
            return ERR_422;
        }

        Uni<Response>  result = client.preparedQuery(TRANSACAO_QUERY)
                .execute(Tuple.of(id, amountFinal, kind, description))
                .onItem().transform(RowSet::iterator)
                .onItem().transform(iterator -> iterator.hasNext() ? responseOf(iterator.next()) : null)
                .onFailure().recoverWithItem(e -> errorOf(e, "err_transacao"));
        
        return result;
    }

    private static String getEnv(String varName, String defaultVal) {
        var result = System.getenv(varName);
        return result != null ? result : defaultVal;
    }

    private Response errorOf(Throwable e, String key) {
        // Response.status(422).entity("{\"" + key + "\": \"" + e.getMessage() + "\"}").build()
        return RES_422;
    }

    private Response responseOf(Row r) {
        return Response
            .status(r.getInteger(0))
            .entity(r.getJson(1))
            .build();
    }
}