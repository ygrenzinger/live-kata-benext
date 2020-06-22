package tcg.domain

import java.util.*

sealed class Event {
    abstract val aggregateIdentifier: UUID
}

data class FirstPlayerChosen(override val aggregateIdentifier: UUID, val player: Player) : Event()