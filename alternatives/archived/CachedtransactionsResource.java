package caravanacloud;

import java.util.Map;

import org.infinispan.Cache;

import io.quarkus.infinispan.client.Remote;
import io.quarkus.logging.Log;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/cached/members/{id}/transactions")
public class CachedtransactionsResource {
    @Inject
    Cache<Integer, Cliente> members;
    
    // curl -v -X POST -H "Content-Type: application/json" -d "{"amount": 1, 'kind': 'c', 'description': 'rinah rox'}" http://localhost:9999/simple/members/1/transactions
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Transactional
    public Response postTransacao(
            @PathParam("id") Integer id,
            Transacao t) {
        Log.tracef("Transacao recebida: %s %s ", id, t);
        var cliente = members.get(id);
        if (cliente == null) {
            return Response.status(404).entity("Cliente nao encontrado").build();
        }
        var result = Map.of(
            "limit", cliente.limit,
            "current_balance", cliente.current_balance
        );
        return Response.ok(result).build();
    }

}
