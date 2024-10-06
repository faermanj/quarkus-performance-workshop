package caravanacloud.pgsql;

import java.sql.SQLException;
import java.util.Map;

import javax.sql.DataSource;

import io.quarkus.logging.Log;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;

@Path("/pgsql/clientes/{id}/transactions")
public class transactionsResource {
    @Inject
    DataSource ds;

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Transactional
    public Response postTransacao(
            @PathParam("id") Integer id,
            Map<String, Object> t) {
        Log.tracef("Transacao recebida: %s %s ", id, t);

        // TODO Uma validação por vez ou múltiplas validations conjuntas ???
        var amountNumber = (Number) t.get("amount");
        if (amountNumber == null
                || !Integer.class.equals(amountNumber.getClass())) {
            return Response.status(422).entity("Valor invalido").build();
        }
        Integer amount = amountNumber.intValue();

        var kind = (String) t.get("kind");
        if (kind == null
                || !("c".equals(kind) || "d".equals(kind))) {
            return Response.status(422).entity("Tipo invalido").build();
        }

        var description = (String) t.get("description");
        if (description == null
                || description.isEmpty()
                || description.length() > 10) {
            return Response.status(422).entity("Descricao invalida").build();
        }

        var query = "select * from proc_transacao(?, ?, ?, ?)";

        try (var conn = ds.getConnection();
                var stmt = conn.prepareStatement(query);) { // TODO cache statement?
            stmt.setInt(1, id);
            stmt.setInt(2, amount);
            stmt.setString(3, kind);
            stmt.setString(4, description);
            stmt.execute();
            try (var rs = stmt.getResultSet()) {
                if (rs.next()) {
                    Integer current_balance = rs.getInt("current_balance");
                    Integer limit = rs.getInt("limit");

                    if (current_balance < -1 * limit) {
                        Log.error("*** LIMITE ULTRAPASSADO " + current_balance + " / " + limit);
                        Log.error(t);
                    }

                    var body = Map.of("limit", limit,
                            "current_balance", current_balance);
                    stmt.close();
                    return Response.ok(body).build();
                } else {
                    return Response.status(500).entity("Erro ao processar a transacao").build();
                }
            }
        } catch (SQLException e) {
            var msg = e.getMessage();
            if (msg.contains("LIMITE_INDISPONIVEL")) {
                return Response.status(422).entity("Erro: Limite indisponivel").build();
            }
            if (msg.contains("fk_clientes_transactions_id")) {
                return Response.status(Status.NOT_FOUND).entity("Erro: Cliente inexistente").build();
            }
            //e.printStackTrace();
            //throw new WebApplicationException("Erro SQL ao processar a transacao", 500);
            Log.debug("Erro ao processar a transacao", e);
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Erro SQL ao processar a transacao").build();
        } catch (Exception e) {
            //e.printStackTrace();
            Log.error("Erro ao processar a transacao", e);
            //throw new WebApplicationException("Erro ao processar a transacao", 500);
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Erro SQL ao processar a transacao").build();
        }
    }

}

