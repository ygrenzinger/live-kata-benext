package tcg.domain

import java.util.*

sealed class Event {
    abstract val aggregateIdentifier: UUID
}

data class GameCreated(
    override val aggregateIdentifier: UUID,
    val usernames: Pair<String, String>
) : Event()

data class GameStarted(
    override val aggregateIdentifier: UUID,
    val firstPlayer: String
) : Event()

data class ManaIncreased(
    override val aggregateIdentifier: UUID,
    val username: String,
    val value: Int
) : Event()

data class CardDrawn(
    override val aggregateIdentifier: UUID,
    val username: String,
    val deck: Deck,
    val hand: Hand
) : Event()
