package tcg.domain.runner

import arrow.core.Either
import tcg.domain.core.Event
import java.util.*

abstract class EventStore {
    private var projections: Map<String, Projection> = emptyMap()

    protected abstract fun persistEvents(aggregateIdentifier: UUID, events: List<Event>)
    abstract fun retrieveEvents(aggregateIdentifier: UUID): List<Event>
    fun storeEvents(aggregateIdentifier: UUID, events: List<Event>) {
        observe(events)
        persistEvents(aggregateIdentifier, events)
    }

    fun storeAndRetrieveEvents(aggregateIdentifier: UUID, events: List<Event>): Either<String, List<Event>> {
        return try {
            storeEvents(aggregateIdentifier, events)
            Either.right(retrieveEvents(aggregateIdentifier))
        } catch (t: Throwable) {
            Either.left(t.message ?: "no error message")
        }
    }

    fun addProjection(projection: Projection) {
        projections = projections + (projection.name to projection)
    }

    fun get(name: String) = projections[name]

    private fun observe(events: List<Event>) {
        projections = projections.mapValues { entry ->
            events.fold(entry.value) { acc, event -> acc.evolve(event) }
        }
    }
}
