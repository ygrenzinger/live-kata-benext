package tcg.domain

import java.util.*

data class GameAggregate(val gameId: UUID, val game: Game = NoGame) {

    fun handle(command: Command): List<Event> {
        return when (command) {
            is CreateGame -> createGame(command)
            is StartGame -> startGame(command)
            is StartTurn -> startTurn(command)
        }
    }

    private fun startGame(command: StartGame): List<Event> {
        return when (game) {
            is CreatingGame -> {
                val firstPlayer = command.chooseFirstPlayer(game.players)
                listOf(
                    GameStarted(gameId, firstPlayer.username),
                    ManaIncreased(gameId, firstPlayer.username, 1),
                    drawCard(firstPlayer, command.cardDealer, 3),
                    drawCard(game.players.retrieveOther(firstPlayer.username), command.cardDealer, 4)
                )
            }
            else -> emptyList()
        }
    }

    private fun createGame(command: CreateGame): List<Event> {
        return when (game) {
            NoGame -> listOf(GameCreated(gameId, command.usernames))
            else -> emptyList()
        }
    }

    private fun startTurn(command: StartTurn) : List<Event> {
        return when (game) {
            is RunnningGame -> listOf(drawCard(game.players.retrieve(game.activePlayer), { deck, _-> command.cardDealer(deck)}, 1))
            else -> emptyList()
        }
    }

    private fun drawCard(
        player: Player,
        cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>,
        n: Int
    ): CardDrawn {
        val (deck, cards) = cardDealer(player.deck, n)
        return CardDrawn(gameId, player.username, deck, player.hand + cards)
    }

    fun evolve(event: Event): GameAggregate {
        return when (game) {
            NoGame -> when (event) {
                is GameCreated -> this.copy(game = game.createGame(event.usernames))
                else -> this
            }
            is CreatingGame -> when (event) {
                is GameStarted -> this.copy(game = game.startGame(event.firstPlayer))
                else -> this
            }
            is RunnningGame -> when (event) {
                is GameCreated -> this
                is GameStarted -> this
                is ManaIncreased -> this.copy(game = game.retrieveAndUpdate(event.username) { player -> player.increaseMana(event.value) })
                is CardDrawn -> this.copy(game = game.playerDrawCards(event.username, event.deck, event.hand))
            }
        }
    }

    companion object {
        fun create(gameId: UUID, events: List<Event>) =
            events.fold(GameAggregate(gameId)) { game, event -> game.evolve(event)}
    }

}