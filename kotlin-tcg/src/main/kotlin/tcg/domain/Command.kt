package tcg.domain

import java.util.*

sealed class Command {
    abstract val aggregateIdentifier: UUID
}

data class SetActivePlayer(override val aggregateIdentifier: UUID, val choosePlayer: (players: Collection<Player>) -> String) : Command()

data class PlayerDrawCards(override val aggregateIdentifier: UUID, val username: String, val cardDealer : (Deck) -> Pair<Deck, List<Card>>) : Command()

