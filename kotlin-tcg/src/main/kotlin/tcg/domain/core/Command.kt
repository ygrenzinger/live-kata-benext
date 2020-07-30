package tcg.domain.core

import java.util.*

sealed class Command {
    abstract val aggregateIdentifier: UUID
}

data class CreateGame(
    override val aggregateIdentifier: UUID,
    val usernames: Pair<String, String>
) : Command()

data class StartGame(override val aggregateIdentifier: UUID) : Command()

data class FirstTurn(override val aggregateIdentifier: UUID) : Command()

data class DealDamageWithCard(
    override val aggregateIdentifier: UUID,
    val card: Card
) : Command()

data class SwitchPlayer(override val aggregateIdentifier: UUID) : Command()
