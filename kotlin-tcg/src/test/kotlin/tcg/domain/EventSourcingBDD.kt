package tcg.domain

import arrow.core.Either
import io.kotest.matchers.shouldBe
import java.util.*

object EventSourcingBDD {
    lateinit var gameAggregate: GameAggregate
    lateinit var result: Either<String, List<Event>>

    fun given(gameId: UUID, vararg events: Event): EventSourcingBDD {
        gameAggregate = GameAggregate.create(gameId, events.toList())
        return this
    }

    fun given(gameId: UUID, events: List<Event>): EventSourcingBDD {
        gameAggregate = GameAggregate.create(gameId, events)
        return this
    }

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