package tcg.domain

import java.util.*

interface EventStore {
    fun storeEvent(event: Event)
    fun retrieveEvents(aggregateIdentifier: UUID) : List<Event>
}
