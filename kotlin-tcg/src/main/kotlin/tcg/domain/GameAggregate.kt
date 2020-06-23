package tcg.domain

import java.util.*

data class GameAggregate(val id: UUID, val eventStore: EventStore, val players: Pair<Player, Player>, val currentPlayer: Player? = null) {

    fun retrievePlayer(username: String) = when (username) {
            players.first.username -> {
                players.first
            }
            players.second.username -> {
                players.second
            }
            else -> {
                null
            }
        }

    fun process(command: Command): GameAggregate {
        val event = when (command) {
            is ChooseFirstPlayer -> FirstPlayerChosen(id, command.player)
            is PlayerDrawCards -> {
                val player = retrievePlayer(command.username)!!
                val (cards, deck) = command.cardDealer(player.deck)
                CardDrawn(id, player.username, cards,deck)
            }
        }

        eventStore.storeEvent(event)
        return evolve(event)
    }

    fun evolve(event: Event) : GameAggregate {
        return when (event) {
            is FirstPlayerChosen -> this.copy(currentPlayer = event.player)
            is CardDrawn -> {
                val player = retrievePlayer(event.username)!!.run {
                    copy(
                        deck = event.deck,
                        hand = this.hand + event.cards
                    )
                }
                this@GameAggregate.copy(
                    players = Pair(player, this.players.second)
                )
            }
        }
    }


}