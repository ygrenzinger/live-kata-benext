package tcg.domain

import java.util.*

data class GameAggregate(val id: UUID, val eventStore: EventStore, val players: Map<String, Player>, val currentPlayer: Player? = null) {

    init {
        require(players.size == 2)
    }

    fun retrievePlayer(username: String): Player = players[username]!!

    fun process(command: Command): GameAggregate {
        val event = when (command) {
            is ChooseFirstPlayer -> FirstPlayerChosen(id, command.player)
            is PlayerDrawCards -> {
                val player = retrievePlayer(command.username)
                val (cards, deck) = command.cardDealer(player.deck)
                CardDrawn(id, player.username, player.hand + cards,deck)
            }
        }

        eventStore.storeEvent(event)
        return evolve(event)
    }

    fun evolve(event: Event) : GameAggregate {
        return when (event) {
            is FirstPlayerChosen -> this.copy(currentPlayer = event.player)
            is CardDrawn -> {
                players[event.username]?.run {
                    copy(deck = event.deck, hand = event.hand)
                }?.let {
                    this@GameAggregate.copy(
                        players = (players + (it.username to it))
                    )
                } ?: this
            }
        }
    }


}