package tcg.domain.core

import io.kotest.core.spec.style.StringSpec
import tcg.domain.core.EventSourcingBDD.given
import tcg.domain.core.Player.Companion.ORIGINAL_DECK
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
            TurnStarted(
                gameId, "A",
                Deck(ORIGINAL_DECK().drop(4)),
                Hand(ORIGINAL_DECK().take(4))
            )
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
            .then(
                TurnStarted(
                    gameId, "A",
                    Deck(ORIGINAL_DECK().drop(4)),
                    Hand(ORIGINAL_DECK().take(4))
                )
            )
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

    "Switching player" {
        given(gameId, firstTurnStarted(gameId))
            .`when`(SwitchPlayer(gameId))
            .then(
                TurnStarted(
                    gameId, "B",
                    Deck(ORIGINAL_DECK().drop(5)),
                    Hand(ORIGINAL_DECK().take(5))
                )
            )
    }

    "Killing opponent" {
        val almostKilledEvents: List<Event> = firstTurnStarted(gameId) +
                (1..7).flatMap {
                    listOf(
                        DamageDealtWithCard(gameId, Card(it), "A", "B"),
                        TurnStarted(
                            gameId,
                            "B",
                            Deck(ORIGINAL_DECK().drop(5 + it)),
                            Hand(ORIGINAL_DECK().take(5 + it))
                        ),
                        TurnStarted(
                            gameId, "A",
                            Deck(ORIGINAL_DECK().drop(4 + it)),
                            Hand(ORIGINAL_DECK().take(4 + it))
                        )
                    )

                }
        given(gameId, almostKilledEvents)
            .`when`(DealDamageWithCard(gameId, Card(3)))
            .then(
                DamageDealtWithCard(gameId, Card(3), "A", "B"),
                PlayerKilled(gameId, players.second)
            )
    }

    "Discarding card" {
        val events = firstTurnStarted(gameId) + listOf(
            TurnStarted(
                gameId, "B",
                Deck(ORIGINAL_DECK().drop(5)),
                Hand(ORIGINAL_DECK().take(5))
            ),
            TurnStarted(
                gameId, "A",
                Deck(ORIGINAL_DECK().drop(5)),
                Hand(ORIGINAL_DECK().take(5))
            )
        )
        given(gameId, events)
            .`when`(SwitchPlayer(gameId))
            .then(
                TurnStarted(
                    gameId, "B",
                    Deck(ORIGINAL_DECK().drop(6)),
                    Hand(ORIGINAL_DECK().take(5))
                )
            )
    }

    "Bleeding" {
        val bleedingEvents: List<Event> = firstTurnStarted(gameId) + listOf(
            TurnStarted(
                gameId, "B",
                Deck(ORIGINAL_DECK().drop(5)),
                Hand(ORIGINAL_DECK().take(5))
            ),
            TurnStarted(
                gameId, "A",
                Deck(ORIGINAL_DECK().drop(5)),
                Hand(ORIGINAL_DECK().take(5))
            )
        ) + (1..29).flatMap {
            listOf(
                TurnStarted(
                    gameId, "B",
                    Deck(ORIGINAL_DECK().drop(5 + it)),
                    Hand(ORIGINAL_DECK().take(5))
                ),
                TurnStarted(
                    gameId, "A",
                    Deck(ORIGINAL_DECK().drop(5 + it)),
                    Hand(ORIGINAL_DECK().take(5))
                )
            )
        }
        given(gameId, bleedingEvents)
            .`when`(SwitchPlayer(gameId))
            .then(
                PlayerBleed(gameId, players.second),
                TurnStarted(
                    gameId, "B",
                    Deck(emptyList()),
                    Hand(ORIGINAL_DECK().take(5))
                )
            )
    }

    "Bleeding and dying" {
        val bleedingEvents: List<Event> = firstTurnStarted(gameId) +
                (1..30).flatMap {
                    listOf(PlayerBleed(gameId, "B"))
                }
        given(gameId, bleedingEvents)
            .`when`(SwitchPlayer(gameId))
            .then(PlayerBleedToDeath(gameId, players.second))
    }

})
