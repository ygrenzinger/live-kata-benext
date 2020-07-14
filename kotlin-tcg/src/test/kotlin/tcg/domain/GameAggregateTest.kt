package tcg.domain

import io.kotest.core.spec.style.StringSpec
import tcg.domain.EventSourcingBDD.given
import tcg.domain.Player.Companion.ORIGINAL_DECK
import java.util.*

class GameAggregateTest : StringSpec({
    lateinit var gameId: UUID
    val players = Pair("A", "B")

    fun buildGameStarted(
        gameId: UUID
    ): GameStarted {
        val (firstPlayerDeck, firstPlayerCards) = ORIGINAL_DECK.take(3)
        val (secondPlayerDeck, secondPlayerCards) = ORIGINAL_DECK.take(4)
        return GameStarted(
            gameId,
            players.first,
            firstPlayerDeck,
            Hand(firstPlayerCards),
            secondPlayerDeck,
            Hand(secondPlayerCards)
        )
    }

    fun firstTurnStarted(gameId: UUID): List<Event> {
        return listOf(
            GameCreated(gameId, players),
            buildGameStarted(gameId),
            TurnStarted(gameId, Deck(ORIGINAL_DECK().drop(4)), Hand(ORIGINAL_DECK().take(4)))
        )
    }


    beforeTest {
        gameId = UUID.randomUUID()
    }

    "creating game" {
        given(gameId)
            .`when`(CreateGame(gameId, players))
            .then(GameCreated(gameId, players))
    }

    "starting game" {
        given(gameId, GameCreated(gameId, players))
            .`when`(StartGame(gameId))
            .then(buildGameStarted(gameId))
    }

    "starting turn" {
        given(
            gameId,
            GameCreated(gameId, players),
            buildGameStarted(gameId)
        ).`when`(FirstTurn(gameId))
            .then(TurnStarted(gameId, Deck(ORIGINAL_DECK().drop(4)), Hand(ORIGINAL_DECK().take(4))))
    }

    "Playing card with enough mana" {
        given(gameId, firstTurnStarted(gameId))
            .`when`(DealDamageWithCard(gameId, Card(1)))
            .then(
                DamageDealtWithCard(gameId, Card(1), "A", "B")
            )
    }

    "Trying to play card with not enough mana" {
        given(
            gameId, firstTurnStarted(gameId)
                    + DamageDealtWithCard(gameId, Card(1), "A", "B")
        ).`when`(DealDamageWithCard(gameId, Card(1)))
            .expectError("not enough mana to play card 1")
    }

    "Trying to play card not in deck" {
        given(
            gameId, firstTurnStarted(gameId)
                    + DamageDealtWithCard(gameId, Card(0), "A", "B")
                    + DamageDealtWithCard(gameId, Card(0), "A", "B")
        ).`when`(DealDamageWithCard(gameId, Card(0)))
            .expectError("card 0 is not in hand")
    }

    "Switch player" {
        given(gameId, firstTurnStarted(gameId))
            .`when`(SwitchPlayer(gameId))
            .then(
                PlayerSwitched(gameId),
                TurnStarted(gameId, Deck(ORIGINAL_DECK().drop(5)), Hand(ORIGINAL_DECK().take(5)))
            )
    }

//    "Player killed" {
//        given(gameId, firstTurnStarted(gameId)
//                + (1..10).flatMap {
//
//        }).`when`(SwitchPlayer(gameId) { deck -> deck.take(1) })
//            .then(
//                PlayerKilled(gameId, players.second)
//            )
//    }

})
