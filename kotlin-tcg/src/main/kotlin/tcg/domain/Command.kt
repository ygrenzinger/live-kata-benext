package tcg.domain

import java.util.*

sealed class Command {
    abstract val aggregateIdentifier: UUID
}

data class ChooseFirstPlayer(override val aggregateIdentifier: UUID, val player: Player) : Command()

