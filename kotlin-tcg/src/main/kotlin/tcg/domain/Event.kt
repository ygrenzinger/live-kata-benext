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
    val firstPlayer: String,
    val firstPlayerDeck: Deck,
    val firstPlayerHand: Hand,
    val secondPlayerDeck: Deck,
    val secondPlayerHand: Hand
) : Event()

data class TurnStarted(
    override val aggregateIdentifier: UUID,
    val playerDeck: Deck,
    val playerHand: Hand
) : Event()

data class DamageDealtWithCard(
    override val aggregateIdentifier: UUID,
    val cardUsed: Card,
    val playerAttacking: String,
    val playerAttacked: String
) : Event()

data class PlayerSwitched(override val aggregateIdentifier: UUID) : Event()

//data class PlayerKilled(override val aggregateIdentifier: UUID, val playerKilled: String) : Event()
