import scala.concurrent.duration._

import scala.util.Random

import util.Try

import io.gatling.commons.validation._
import io.gatling.core.session.Session
import io.gatling.core.Predef._
import io.gatling.http.Predef._


class RinhaBackendCrebitosSimulation
  extends Simulation {

  def randomClienteId() = Random.between(1, 5 + 1)
  def randomValorTransacao() = Random.between(1, 10000 + 1)
  def randomDescricao() = Random.alphanumeric.take(10).mkString
  def randomTipoTransacao() = Seq("c", "d", "d")(Random.between(0, 2 + 1)) // not used
  def toInt(s: String): Option[Int] = {
    try {
      Some(s.toInt)
    } catch {
      case e: Exception => None
    }
  }

  val validarConsistenciaSaldoLimite = (valor: Option[String], session: Session) => {
    /*
      Essa função é frágil porque depende que haja uma entrada
      chamada 'limite' com valor conversível para int na session
      e também que seja encadeada com com jmesPath("saldo") para
      que 'valor' seja o primeiro argumento da função validadora
      de 'validate(.., ..)'.
      
      =============================================================
      
      Nota para quem não tem experiência em testes de performance:
        O teste de lógica de saldo/limite extrapola o que é comumente 
        feito em testes de performance apenas por causa da natureza
        da Rinha de Backend. Evite fazer esse tipo de coisa em 
        testes de performance, pois não é uma prática recomendada
        normalmente.
    */ 

    val saldo = valor.flatMap(s => Try(s.toInt).toOption)
    val limite = toInt(session("limite").as[String])

    (saldo, limite) match {
      case (Some(s), Some(l)) if s.toInt < l.toInt * -1 => Failure("Limite ultrapassado!")
      case (Some(s), Some(l)) if s.toInt >= l.toInt * -1 => Success(Option("ok"))
      case _ => Failure("WTF?!")
    }
  }

  val httpProtocol = http
    .baseUrl("http://localhost:9999")
    .userAgentHeader("Agente do Caos - 2024/Q1")

  val debitos = scenario("debits")
    .exec {s =>
      val descricao = randomDescricao()
      val cliente_id = randomClienteId()
      val valor = randomValorTransacao()
      val payload = s"""{"valor": ${valor}, "tipo": "d", "descricao": "${descricao}"}"""
      val session = s.setAll(Map("descricao" -> descricao, "cliente_id" -> cliente_id, "payload" -> payload))
      session
    }
    .exec(
      http("debits")
      .post(s => s"/members/${s("cliente_id").as[String]}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s => s("payload").as[String]))
          .check(
            status.in(200, 422),
            status.saveAs("httpStatus"))
          .checkIf(s => s("httpStatus").as[String] == "200") { jmesPath("limite").saveAs("limite") }
          .checkIf(s => s("httpStatus").as[String] == "200") {
            jmesPath("saldo").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          }
    )

  val creditos = scenario("credits")
    .exec {s =>
      val descricao = randomDescricao()
      val cliente_id = randomClienteId()
      val valor = randomValorTransacao()
      val payload = s"""{"valor": ${valor}, "tipo": "c", "descricao": "${descricao}"}"""
      val session = s.setAll(Map("descricao" -> descricao, "cliente_id" -> cliente_id, "payload" -> payload))
      session
    }
    .exec(
      http("credits")
      .post(s => s"/members/${s("cliente_id").as[String]}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s => s("payload").as[String]))
          .check(
            status.in(200),
            jmesPath("limite").saveAs("limite"),
            jmesPath("saldo").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          )
    )

  val balances = scenario("balances")
    .exec(
      http("balances")
      .get(s => s"/members/${randomClienteId()}/balance")
      .check(
        jmesPath("saldo.limite").saveAs("limite"),
        jmesPath("saldo.total").validate("ConsistenciaSaldoLimite - Extrato", validarConsistenciaSaldoLimite)
    )
  )

  val validacaConcorrentesNumRequests = 25
  val validacaotransactionsConcorrentes = (tipo: String) =>
    scenario(s"validating transactions concurrency - ${tipo}")
    .exec(
      http("validations")
      .post(s"/members/1/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "${tipo}", "descricao": "validacao"}"""))
          .check(status.is(200))
    )
  
  val validacaotransactionsConcorrentesSaldo = (saldoEsperado: Int) =>
    scenario(s"validating expected balance - ${saldoEsperado}")
    .exec(
      http("validations")
      .get(s"/members/1/balance")
      .check(
        jmesPath("saldo.total").ofType[Int].is(saldoEsperado)
      )
    )

  val saldosIniciaismembers = Array(
    Map("id" -> 1, "limite" ->   1000 * 100),
    Map("id" -> 2, "limite" ->    800 * 100),
    Map("id" -> 3, "limite" ->  10000 * 100),
    Map("id" -> 4, "limite" -> 100000 * 100),
    Map("id" -> 5, "limite" ->   5000 * 100),
  )

  val criterioClienteNaoEcontrado = scenario("validating HTTP 404")
    .exec(
      http("validations")
      .get("/members/6/balance")
      .check(status.is(404))
    )

  val criteriosmembers = scenario("validations")
    .feed(saldosIniciaismembers)
    .exec(
      /*
        Os valores de http(...) essão duplicados propositalmente
        para que sejam agrupados no relatório e ocupem menos espaço.
        O lado negativo é que, em caso de falha, pode não ser possível
        saber sua causa exata.
      */ 
      http("validations")
      .get("/members/#{id}/balance")
      .check(
        status.is(200),
        jmesPath("saldo.limite").ofType[String].is("#{limite}"),
        jmesPath("saldo.total").ofType[String].is("0")
      )
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "c", "descricao": "toma"}"""))
          .check(
            status.in(200),
            jmesPath("limite").saveAs("limite"),
            jmesPath("saldo").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          )
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "d", "descricao": "devolve"}"""))
          .check(
            status.in(200),
            jmesPath("limite").saveAs("limite"),
            jmesPath("saldo").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          )
    )
    .exec(
      http("validations")
      .get("/members/#{id}/balance")
      .check(
        jmesPath("ultimas_transactions[0].descricao").ofType[String].is("devolve"),
        jmesPath("ultimas_transactions[0].tipo").ofType[String].is("d"),
        jmesPath("ultimas_transactions[0].valor").ofType[Int].is("1"),
        jmesPath("ultimas_transactions[1].descricao").ofType[String].is("toma"),
        jmesPath("ultimas_transactions[1].tipo").ofType[String].is("c"),
        jmesPath("ultimas_transactions[1].valor").ofType[Int].is("1")
      )
    )
    .exec( // Consistencia do balance
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "c", "descricao": "danada"}"""))
          .check(
            status.in(200),
            jmesPath("saldo").saveAs("saldo"),
            jmesPath("limite").saveAs("limite")
          )
          .resources(
            // 5 consultas simultâneas ao balance para verificar consistência
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("ultimas_transactions[0].descricao").ofType[String].is("danada"),
              jmesPath("ultimas_transactions[0].tipo").ofType[String].is("c"),
              jmesPath("ultimas_transactions[0].valor").ofType[Int].is("1"),
              jmesPath("saldo.limite").ofType[String].is("#{limite}"),
              jmesPath("saldo.total").ofType[String].is("#{saldo}")
            ),
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("ultimas_transactions[0].descricao").ofType[String].is("danada"),
              jmesPath("ultimas_transactions[0].tipo").ofType[String].is("c"),
              jmesPath("ultimas_transactions[0].valor").ofType[Int].is("1"),
              jmesPath("saldo.limite").ofType[String].is("#{limite}"),
              jmesPath("saldo.total").ofType[String].is("#{saldo}")
            ),
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("ultimas_transactions[0].descricao").ofType[String].is("danada"),
              jmesPath("ultimas_transactions[0].tipo").ofType[String].is("c"),
              jmesPath("ultimas_transactions[0].valor").ofType[Int].is("1"),
              jmesPath("saldo.limite").ofType[String].is("#{limite}"),
              jmesPath("saldo.total").ofType[String].is("#{saldo}")
            ),
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("ultimas_transactions[0].descricao").ofType[String].is("danada"),
              jmesPath("ultimas_transactions[0].tipo").ofType[String].is("c"),
              jmesPath("ultimas_transactions[0].valor").ofType[Int].is("1"),
              jmesPath("saldo.limite").ofType[String].is("#{limite}"),
              jmesPath("saldo.total").ofType[String].is("#{saldo}")
            )
        )
    )
  
  .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1.2, "tipo": "d", "descricao": "devolve"}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "x", "descricao": "devolve"}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "c", "descricao": "123456789 e mais um pouco"}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "c", "descricao": ""}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"valor": 1, "tipo": "c", "descricao": null}"""))
          .check(status.in(422, 400))
    )

  /* 
    Separar credits e debits dá uma visão
    melhor sobre como as duas operações se
    comportam individualmente.
  */
  setUp(
    validacaotransactionsConcorrentes("d").inject(
      atOnceUsers(validacaConcorrentesNumRequests)
    ).andThen(
      validacaotransactionsConcorrentesSaldo(validacaConcorrentesNumRequests * -1).inject(
        atOnceUsers(1)
      )
    ).andThen(
      validacaotransactionsConcorrentes("c").inject(
        atOnceUsers(validacaConcorrentesNumRequests)
      ).andThen(
        validacaotransactionsConcorrentesSaldo(0).inject(
          atOnceUsers(1)
        )
      )
    ).andThen(
      criteriosmembers.inject(
        atOnceUsers(saldosIniciaismembers.length)
      ),
      criterioClienteNaoEcontrado.inject(
        atOnceUsers(1)
      ).andThen(
        debitos.inject(
          rampUsersPerSec(1).to(220).during(2.minutes),
          constantUsersPerSec(220).during(2.minutes)
        ),
        creditos.inject(
          rampUsersPerSec(1).to(110).during(2.minutes),
          constantUsersPerSec(110).during(2.minutes)
        ),
        balances.inject(
          rampUsersPerSec(1).to(10).during(2.minutes),
          constantUsersPerSec(10).during(2.minutes)
        )
      )
    )
  ).protocols(httpProtocol)
}
