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

  val validarConsistenciaSaldoLimite = (amount: Option[String], session: Session) => {
    /*
      Essa função é frágil porque depende que haja uma entrada
      chamada 'limit' com amount conversível para int na session
      e também que seja encadeada com com jmesPath("current_balance") para
      que 'amount' seja o primeiro argumento da função validadora
      de 'validate(.., ..)'.
      
      =============================================================
      
      Nota para quem não tem experiência em testes de performance:
        O teste de lógica de current_balance/limit extrapola o que é comumente 
        feito em testes de performance apenas por causa da natureza
        da Rinha de Backend. Evite fazer esse kind de coisa em 
        testes de performance, pois não é uma prática recomendada
        normalmente.
    */ 

    val current_balance = amount.flatMap(s => Try(s.toInt).toOption)
    val limit = toInt(session("limit").as[String])

    (current_balance, limit) match {
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
      val description = randomDescricao()
      val cliente_id = randomClienteId()
      val amount = randomValorTransacao()
      val payload = s"""{"amount": ${amount}, "kind": "d", "description": "${description}"}"""
      val session = s.setAll(Map("description" -> description, "cliente_id" -> cliente_id, "payload" -> payload))
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
          .checkIf(s => s("httpStatus").as[String] == "200") { jmesPath("limit").saveAs("limit") }
          .checkIf(s => s("httpStatus").as[String] == "200") {
            jmesPath("current_balance").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          }
    )

  val creditos = scenario("credits")
    .exec {s =>
      val description = randomDescricao()
      val cliente_id = randomClienteId()
      val amount = randomValorTransacao()
      val payload = s"""{"amount": ${amount}, "kind": "c", "description": "${description}"}"""
      val session = s.setAll(Map("description" -> description, "cliente_id" -> cliente_id, "payload" -> payload))
      session
    }
    .exec(
      http("credits")
      .post(s => s"/members/${s("cliente_id").as[String]}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s => s("payload").as[String]))
          .check(
            status.in(200),
            jmesPath("limit").saveAs("limit"),
            jmesPath("current_balance").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          )
    )

  val balances = scenario("balances")
    .exec(
      http("balances")
      .get(s => s"/members/${randomClienteId()}/balance")
      .check(
        jmesPath("current_balance.limit").saveAs("limit"),
        jmesPath("current_balance.total").validate("ConsistenciaSaldoLimite - Extrato", validarConsistenciaSaldoLimite)
    )
  )

  val validacaConcorrentesNumRequests = 25
  val validacaotransactionsConcorrentes = (kind: String) =>
    scenario(s"validating transactions concurrency - ${kind}")
    .exec(
      http("validations")
      .post(s"/members/1/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "${kind}", "description": "validacao"}"""))
          .check(status.is(200))
    )
  
  val validacaotransactionsConcorrentesSaldo = (current_balanceEsperado: Int) =>
    scenario(s"validating expected balance - ${current_balanceEsperado}")
    .exec(
      http("validations")
      .get(s"/members/1/balance")
      .check(
        jmesPath("current_balance.total").ofType[Int].is(current_balanceEsperado)
      )
    )

  val current_balancesIniciaismembers = Array(
    Map("id" -> 1, "limit" ->   1000 * 100),
    Map("id" -> 2, "limit" ->    800 * 100),
    Map("id" -> 3, "limit" ->  10000 * 100),
    Map("id" -> 4, "limit" -> 100000 * 100),
    Map("id" -> 5, "limit" ->   5000 * 100),
  )

  val criterioClienteNaoEcontrado = scenario("validating HTTP 404")
    .exec(
      http("validations")
      .get("/members/6/balance")
      .check(status.is(404))
    )

  val criteriosmembers = scenario("validations")
    .feed(current_balancesIniciaismembers)
    .exec(
      /*
        Os amountes de http(...) essão duplicados propositalmente
        para que sejam agrupados no relatório e ocupem menos espaço.
        O lado negativo é que, em caso de falha, pode não ser possível
        saber sua causa exata.
      */ 
      http("validations")
      .get("/members/#{id}/balance")
      .check(
        status.is(200),
        jmesPath("current_balance.limit").ofType[String].is("#{limit}"),
        jmesPath("current_balance.total").ofType[String].is("0")
      )
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "c", "description": "toma"}"""))
          .check(
            status.in(200),
            jmesPath("limit").saveAs("limit"),
            jmesPath("current_balance").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          )
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "d", "description": "devolve"}"""))
          .check(
            status.in(200),
            jmesPath("limit").saveAs("limit"),
            jmesPath("current_balance").validate("ConsistenciaSaldoLimite - Transação", validarConsistenciaSaldoLimite)
          )
    )
    .exec(
      http("validations")
      .get("/members/#{id}/balance")
      .check(
        jmesPath("recent_transactions[0].description").ofType[String].is("devolve"),
        jmesPath("recent_transactions[0].kind").ofType[String].is("d"),
        jmesPath("recent_transactions[0].amount").ofType[Int].is("1"),
        jmesPath("recent_transactions[1].description").ofType[String].is("toma"),
        jmesPath("recent_transactions[1].kind").ofType[String].is("c"),
        jmesPath("recent_transactions[1].amount").ofType[Int].is("1")
      )
    )
    .exec( // Consistencia do balance
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "c", "description": "danada"}"""))
          .check(
            status.in(200),
            jmesPath("current_balance").saveAs("current_balance"),
            jmesPath("limit").saveAs("limit")
          )
          .resources(
            // 5 consultas simultâneas ao balance para verificar consistência
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("recent_transactions[0].description").ofType[String].is("danada"),
              jmesPath("recent_transactions[0].kind").ofType[String].is("c"),
              jmesPath("recent_transactions[0].amount").ofType[Int].is("1"),
              jmesPath("current_balance.limit").ofType[String].is("#{limit}"),
              jmesPath("current_balance.total").ofType[String].is("#{current_balance}")
            ),
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("recent_transactions[0].description").ofType[String].is("danada"),
              jmesPath("recent_transactions[0].kind").ofType[String].is("c"),
              jmesPath("recent_transactions[0].amount").ofType[Int].is("1"),
              jmesPath("current_balance.limit").ofType[String].is("#{limit}"),
              jmesPath("current_balance.total").ofType[String].is("#{current_balance}")
            ),
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("recent_transactions[0].description").ofType[String].is("danada"),
              jmesPath("recent_transactions[0].kind").ofType[String].is("c"),
              jmesPath("recent_transactions[0].amount").ofType[Int].is("1"),
              jmesPath("current_balance.limit").ofType[String].is("#{limit}"),
              jmesPath("current_balance.total").ofType[String].is("#{current_balance}")
            ),
            http("validations").get("/members/#{id}/balance").check(
              jmesPath("recent_transactions[0].description").ofType[String].is("danada"),
              jmesPath("recent_transactions[0].kind").ofType[String].is("c"),
              jmesPath("recent_transactions[0].amount").ofType[Int].is("1"),
              jmesPath("current_balance.limit").ofType[String].is("#{limit}"),
              jmesPath("current_balance.total").ofType[String].is("#{current_balance}")
            )
        )
    )
  
  .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1.2, "kind": "d", "description": "devolve"}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "x", "description": "devolve"}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "c", "description": "123456789 e mais um pouco"}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "c", "description": ""}"""))
          .check(status.in(422, 400))
    )
    .exec(
      http("validations")
      .post("/members/#{id}/transactions")
          .header("content-type", "application/json")
          .body(StringBody(s"""{"amount": 1, "kind": "c", "description": null}"""))
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
        atOnceUsers(current_balancesIniciaismembers.length)
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
