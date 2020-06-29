package tcg.domain

import java.util.*

sealed class Event {
    abstract val aggregateIdentifier: UUID
}

data class ActivePlayerSet(override val aggregateIdentifier: UUID, val username: String) : Event()

data class CardDrawn(override val aggregateIdentifier: UUID, val username: String, val deck: Deck, val hand: Hand) : Event()
