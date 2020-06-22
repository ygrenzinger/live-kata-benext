package tcg.domain

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainExactly
import io.kotest.matchers.shouldBe
import tcg.domain.*
import tcg.infra.InMemoryEventStore
import java.util.*

class GameAggregateTest : StringSpec({
    lateinit var gameId : UUID
    lateinit var game: GameAggregate
    lateinit var eventStore : EventStore

    beforeTest {
        gameId = UUID.randomUUID()
        eventStore = InMemoryEventStore()
        game = GameAggregate(gameId, eventStore)
    }

    "create game" {
        game.playerA shouldBe Player()
        game.playerB shouldBe Player()
    }

    "choose first player" {
        val updated = game.process(ChooseFirstPlayer(gameId, game.playerA))

        eventStore.retrieveEvents(game.id) shouldContainExactly listOf(
            FirstPlayerChosen(
                gameId,
                game.playerA
            )
        )
        updated.currentPlayer shouldBe game.playerA
    }
})