package tcg.domain

import java.util.*

sealed class Event {
    abstract val aggregateIdentifier: UUID
}

data class FirstPlayerChosen(override val aggregateIdentifier: UUID, val player: Player) : Event()

data class CardDrawn(override val aggregateIdentifier: UUID, val username: String, val hand: List<Card>, val deck: List<Card>) : Event()
