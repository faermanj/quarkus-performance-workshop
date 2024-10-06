package caravanacloud.mysql;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Types;
import java.util.Map;

import javax.sql.DataSource;

import io.quarkus.logging.Log;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.WebApplicationException;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import jakarta.ws.rs.core.Response.Status;

@Path("/mysql/members/{id}/transactions")
public class transactionsResource {
    @Inject
    DataSource ds;

    // curl -v -X POST -H "Content-Type: application/json" -d '{"amount": 100,
    // "kind": "c", "description": "Compra"}'
    // http://localhost:9999/members/1/transactions
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Transactional(Transactional.TxType.NEVER) 
    public Response postTransacao(
            @PathParam("id") Integer id,
            Map<String, Object> t) {
        Log.tracef("Transacao recebida: %s %s ", id, t);

        var amountNumber = (Number) t.get("amount");
        if (amountNumber == null || !Integer.class.equals(amountNumber.getClass())) {
            return Response.status(422).entity("Valor invalido").build();
        }
        Integer amount = amountNumber.intValue();

        var kind = (String) t.get("kind");
        if (kind == null || !("c".equals(kind) || "d".equals(kind))) {
            return Response.status(422).entity("Tipo invalido").build();
        }

        var description = (String) t.get("description");
        if (description == null || description.isEmpty() || description.length() > 10) {
            return Response.status(422).entity("Descricao invalida").build();
        }

        // Adjusted for MySQL
        var query = "{CALL proc_transacao(?, ?, ?, ?, ?, ?)}";

        try (var conn = ds.getConnection();
                var stmt = conn.prepareCall(query)) {
            conn.setAutoCommit(false);
            conn.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);

            stmt.setInt(1, id);
            stmt.setInt(2, amount);
            stmt.setString(3, kind);
            stmt.setString(4, description);

            stmt.registerOutParameter(5, Types.INTEGER);
            stmt.registerOutParameter(6, Types.INTEGER);
            var hasResults = stmt.execute();
            if(! hasResults){
                return Response.status(Status.NOT_FOUND).entity("NO RESULT").build();

            }
            try (var rs = stmt.getResultSet()) {
                if (rs.next()){
                    var current_balance =  rs.getInt(1);
                    var limit =  rs.getInt(2);

                    if (current_balance < -1 * limit) {
                        Log.error("*** LIMITE ULTRAPASSADO " + current_balance + " / " + limit);
                        Log.error(t.toString());
                        throw new WebApplicationException("ERRO DE CONSISTENCIA", 422);
                    }

                    var body = Map.of("limit", limit, "current_balance", current_balance);
                    return Response.ok(body).build();
                } else{
                    return Response.status(500).entity("Erro: no next").build();
                }
            }catch(SQLException e){
                e.printStackTrace();
                return Response.status(404).entity("NAO ENTROU").build();
            }
        } catch (SQLException e) {
            var msg = e.getMessage();
            //Log.warnf("Message %s", e.getMessage());
            //Log.warnf("Code: "+e.getErrorCode());
            if (msg != null){
                if (msg.contains("LIMITE_INDISPONIVEL")) {
                    return Response.status(422).entity("Erro: Limite indisponivel").build();
                }
                if (msg.contains("fk_members_transactions_id")) {
                    return Response.status(Status.NOT_FOUND).entity("Erro: Cliente inexistente").build();
                }
                if (msg.contains("CLIENTE_NAO_ENCONTRADO")) {
                    return Response.status(Status.NOT_FOUND).entity("Erro: Cliente inexistente").build();
                }
            }
            Log.debug("Erro ao processar a transacao - sql", e);
            e.printStackTrace();
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Erro SQL ao processar a transacao").build();
        } catch (Exception e) {
            Log.error("Erro ao processar a transacao - ex", e);
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("Erro ao processar a transacao").build();
        }
    }
}
