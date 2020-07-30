package tcg.domain.core

import arrow.core.Either
import io.kotest.matchers.shouldBe
import java.util.*

object EventSourcingBDD {
    lateinit var gameAggregate: GameAggregate
    lateinit var result: Either<String, List<Event>>

    fun given(gameId: UUID, vararg events: Event): EventSourcingBDD {
        gameAggregate =
            createAggregate(gameId, events.toList())
        return this
    }

    fun given(gameId: UUID, events: List<Event>): EventSourcingBDD {
        gameAggregate =
            createAggregate(gameId, events)
        return this
    }

    private fun createAggregate(
        gameId: UUID,
        events: List<Event>
    ) = GameAggregate.create(gameId, { players -> players.first }, { deck, n -> deck.take(n) }, events)

    fun `when`(command: Command): EventSourcingBDD {
        result = gameAggregate.handle(command)
        return this
    }

    fun then(vararg expectedEvents: Event) {
        result shouldBe Either.right(expectedEvents.toList())
    }

    fun then(f: () -> List<Event>) {
        result shouldBe Either.right(f())
    }

    fun expectError(error: String) {
        result shouldBe Either.left(error)
    }
}