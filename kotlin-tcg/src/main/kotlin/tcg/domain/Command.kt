package tcg.domain

import java.util.*

sealed class Command {
    abstract val aggregateIdentifier: UUID
}

data class ChooseFirstPlayer(override val aggregateIdentifier: UUID, val player: Player) : Command()

data class PlayerDrawCards(override val aggregateIdentifier: UUID, val username: String, val cardDealer : (List<Card>) -> Pair<List<Card>, List<Card>>) : Command()

