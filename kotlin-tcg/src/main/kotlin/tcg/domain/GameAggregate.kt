package tcg.domain

import arrow.core.Either
import java.util.*

data class GameAggregate(val gameId: UUID, val game: Game = NoGame) {

    fun handle(command: Command): Either<String, List<Event>> {
        return when (command) {
            is CreateGame -> createGame(command)
            is StartGame -> startGame(command)
            is StartTurn -> startTurn(command)
            is DealDamageWithCard -> dealDamage(command)
        }
    }

    private fun dealDamage(command: DealDamageWithCard): Either<String, List<Event>> {
        return when (game) {
            is RunnningGame -> {
                return if (game.active().filledManaSlot < command.card()) {
                    Either.left("not enough mana to play card ${command.card()}")
                } else if (command.card !in game.active().hand) {
                    Either.left("card ${command.card()} is not in hand")
                } else {
                    Either.right(
                        listOf(
                            DamageDealtWithCard(
                                command.aggregateIdentifier,
                                command.card,
                                game.active().username,
                                game.opponent().username
                            )
                        )
                    )
                }
            }
            else -> Either.left("wrong game state")
        }
    }

    private fun startGame(command: StartGame): Either<String, List<Event>> {
        return when (game) {
            is CreatingGame -> {
                val firstPlayer = command.chooseFirstPlayer(game.players)
                val (firstPlayerDeck, firstPlayerCards) = command.cardDealer(firstPlayer.deck, 3)
                val secondPlayer = game.players.retrieveOther(firstPlayer.username)
                val (secondPlayerDeck, secondPlayerCards) = command.cardDealer(secondPlayer.deck, 4)
                Either.right(
                    listOf(
                        GameStarted(
                            gameId,
                            firstPlayer.username,
                            firstPlayerDeck,
                            Hand(firstPlayerCards),
                            secondPlayerDeck,
                            Hand(secondPlayerCards)
                        )
                    )
                )
            }
            else -> Either.left("wrong game state")
        }
    }

    private fun createGame(command: CreateGame): Either<String, List<Event>> {
        return when (game) {
            NoGame -> Either.right(listOf(GameCreated(gameId, command.usernames)))
            else -> Either.left("wrong game state")
        }
    }

    private fun startTurn(command: StartTurn): Either<String, List<Event>> {
        return when (game) {
            is RunnningGame -> {
                val player = game.active()
                val (deck, cards) = command.cardDealer(player.deck)
                Either.right(listOf(TurnStarted(command.aggregateIdentifier, deck, player.hand.plus(cards))))
            }
            else -> Either.left("wrong game state")
        }
    }

    fun evolve(event: Event): GameAggregate {
        return when (game) {
            is NoGame -> when (event) {
                is GameCreated -> this.copy(game = game.createGame(event.usernames))
                else -> this
            }
            is CreatingGame -> when (event) {
                is GameStarted -> this.copy(game = game.startGame(event))
                else -> this
            }
            is RunnningGame -> when (event) {
                is GameCreated -> this
                is GameStarted -> this
                is TurnStarted -> this.copy(game = game.startTurn(event.playerDeck, event.playerHand))
                is DamageDealtWithCard -> this.copy(
                    game = game.dealindDamageWithCard(
                        event.cardUsed,
                        event.playerAttacking,
                        event.playerAttacked
                    )
                )
            }
        }
    }

    companion object {
        fun create(gameId: UUID, events: List<Event>) =
            events.fold(GameAggregate(gameId)) { game, event -> game.evolve(event) }
    }

}