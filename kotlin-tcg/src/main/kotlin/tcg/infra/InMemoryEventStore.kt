package tcg.infra

import tcg.domain.Event
import tcg.domain.EventStore
import java.util.*

class InMemoryEventStore : EventStore{
    private val data = mutableMapOf<UUID, List<Event>>()

    override fun storeEvent(event: Event) {
        data.compute(event.aggregateIdentifier) { id, events ->
            if (events.isNullOrEmpty()) {
                listOf(event)
            } else {
                events + event
            }
        }
    }

    override fun retrieveEvents(aggregateIdentifier: UUID) =
        data[aggregateIdentifier] ?: emptyList()

}