package tcg.domain

import java.util.*

data class GameAggregate(val id: UUID, val eventStore: EventStore, val playerA: Player = Player(), val playerB: Player = Player(), val currentPlayer: Player? = null) {

    fun process(command: Command): GameAggregate {
        val event = when (command) {
            is ChooseFirstPlayer -> FirstPlayerChosen(id, command.player)
        }

        eventStore.storeEvent(event)
        return evolve(event)
    }

    fun evolve(event: Event) : GameAggregate {
        return when (event) {
            is FirstPlayerChosen -> this.copy(currentPlayer = event.player)
        }
    }


}