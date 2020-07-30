package tcg.infra

import tcg.domain.core.Event
import tcg.domain.runner.EventStore
import java.util.*

class InMemoryEventStore : EventStore() {
    private val data = mutableMapOf<UUID, List<Event>>()

    override fun persistEvents(aggregateIdentifier: UUID, events: List<Event>) {
        data.compute(aggregateIdentifier) { _, existingEvents ->
            if (existingEvents.isNullOrEmpty()) {
                events
            } else {
                existingEvents + events
            }
        }
    }

    override fun retrieveEvents(aggregateIdentifier: UUID) =
        data[aggregateIdentifier] ?: emptyList()

}