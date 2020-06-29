package tcg.domain

import java.util.*

data class GameAggregate(val id: UUID, val eventStore: EventStore, val game: Game) {

    fun process(command: Command): GameAggregate {
        val event = when (command) {
            is SetActivePlayer -> ActivePlayerSet(id, command.choosePlayer(game.players()))
            is PlayerDrawCards -> {
                val player = game.retrievePlayer(command.username)
                val (deck, cards) = command.cardDealer(player.deck)
                CardDrawn(id, player.username, deck, player.hand + cards)
            }
        }

        eventStore.storeEvent(event)
        return evolve(event)
    }

    fun evolve(event: Event): GameAggregate {
        return when (event) {
            is ActivePlayerSet -> this.copy(game = game.setActivePlayer(event.username))
            is CardDrawn -> this.copy(game = game.playerDrawCards(event.username, event.deck, event.hand))
        }
    }


}