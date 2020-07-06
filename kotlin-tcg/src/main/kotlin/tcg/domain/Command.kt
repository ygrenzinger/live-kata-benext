package tcg.domain

import java.util.*

sealed class Command {
    abstract val aggregateIdentifier: UUID
}

data class CreateGame(
    override val aggregateIdentifier: UUID,
    val usernames: Pair<String, String>
) : Command()

data class StartGame(
    override val aggregateIdentifier: UUID,
    val chooseFirstPlayer: (players: Pair<Player, Player>) -> Player,
    val cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>
) : Command()
