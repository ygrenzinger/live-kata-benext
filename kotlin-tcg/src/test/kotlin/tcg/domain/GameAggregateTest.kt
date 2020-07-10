package tcg.domain

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainExactly
import tcg.domain.EventSourcingBDD.given
import tcg.domain.Player.Companion.ORIGINAL_DECK
import java.util.*

class GameAggregateTest : StringSpec({
    lateinit var gameId: UUID
    val players = Pair("A", "B")

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
            .`when`(StartGame(gameId, { players -> players.first }, { deck, n -> deck.take(n) }))
            .then(
                GameStarted(gameId, players.first),
                ManaIncreased(gameId, players.first, 1),
                buildCardDrawnEvent(gameId, players.first, ORIGINAL_DECK, 3),
                buildCardDrawnEvent(gameId, players.second, ORIGINAL_DECK, 4)
            )
    }

    "starting turn" {

        given(gameId,
            GameCreated(gameId, players),
            GameStarted(gameId, players.first),
            ManaIncreased(gameId, players.first, 1),
            buildCardDrawnEvent(gameId, players.first, ORIGINAL_DECK, 3),
            buildCardDrawnEvent(gameId, players.second, ORIGINAL_DECK, 4)
        ).`when`(StartTurn(gameId) { deck -> deck.take(1) })
            .then {
                listOf(CardDrawn(gameId, players.first, Deck(ORIGINAL_DECK().drop(4)), Hand(ORIGINAL_DECK().take(4))))
            }
    }

})

object EventSourcingBDD {
    lateinit var gameAggregate: GameAggregate
    lateinit var events: List<Event>

    fun given(gameId: UUID, vararg  events: Event): EventSourcingBDD {
        gameAggregate = GameAggregate.create(gameId, events.toList())
        return this
    }

    fun `when`(command: Command): EventSourcingBDD {
        events = gameAggregate.handle(command)
        return this
    }

    fun then(vararg expectedEvents: Event) {
        events shouldContainExactly expectedEvents.toList()
    }

    fun then(f: () -> List<Event>) {
        events shouldContainExactly f()
    }
}

private fun buildCardDrawnEvent(gameId: UUID, username: String, deck: Deck, nbCardsToDraw: Int): CardDrawn {
    val (updated, cards) = deck.take(nbCardsToDraw)
    val hand = Hand(cards)
    return CardDrawn(gameId, username, updated, hand)
}