package tcg.domain.core

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
    val player: String,
    val playerDeck: Deck,
    val playerHand: Hand
) : Event()

data class DamageDealtWithCard(
    override val aggregateIdentifier: UUID,
    val card: Card,
    val playerAttacking: String,
    val playerAttacked: String
) : Event()

data class PlayerKilled(
    override val aggregateIdentifier: UUID,
    val playerKilled: String
) : Event()

data class PlayerBleed(
    override val aggregateIdentifier: UUID,
    val player: String
) : Event()

data class PlayerBleedToDeath(
    override val aggregateIdentifier: UUID,
    val playerKilled: String
) : Event()
