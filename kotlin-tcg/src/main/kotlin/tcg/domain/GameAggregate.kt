package tcg.domain

import arrow.core.Either
import java.util.*

data class GameAggregate(
    val gameId: UUID,
    val chooseFirstPlayer: (players: TwoPlayers) -> Player,
    val cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>,
    val game: Game = NoGame
) {

    fun handle(command: Command): Either<String, List<Event>> {
        return when (command) {
            is CreateGame -> createGame(command.usernames)
            is StartGame -> startGame()
            is FirstTurn -> startTurn()
            is DealDamageWithCard -> dealDamage(command.card)
            is SwitchPlayer -> switchPlayer()
        }
    }

    private fun dealDamage(card: Card): Either<String, List<Event>> {
        return when (game) {
            is RunnningGame -> {
                return when {
                    game.active().filledManaSlot < card() -> {
                        Either.left("not enough mana to play card ${card()}")
                    }
                    card !in game.active().hand -> {
                        Either.left("card ${card()} is not in hand")
                    }
                    else -> {
                        val events = mutableListOf<Event>(DamageDealtWithCard(
                            gameId,
                            card,
                            game.active().username,
                            game.opponent().username
                        ))
                        if (game.opponent().health - card() <= 0) {
                            events.add(PlayerKilled(gameId, game.opponent().username))
                        }
                        Either.right(
                            events
                        )
                    }
                }
            }
            else -> Either.left("wrong game state")
        }
    }

    private fun startTurn(): Either<String, List<Event>> {
        return when (game) {
            is RunnningGame -> startTurn(game.active())
            else -> Either.left("wrong game state")
        }
    }

    private fun switchPlayer(): Either<String, List<Event>> {
        return when (game) {
            is RunnningGame -> startTurn(game.opponent())
            else -> Either.left("wrong game state")
        }
    }

    private fun startTurn(player: Player): Either<String, List<Event>> {
        val (deck, cards) = cardDealer(player.deck, 1)
        return Either.right(listOf(TurnStarted(gameId, player.username, deck, player.hand.plus(cards))))
    }

    private fun startGame(): Either<String, List<Event>> {
        return when (game) {
            is CreatingGame -> {
                val firstPlayer = chooseFirstPlayer(game.players)
                val (firstPlayerDeck, firstPlayerCards) = cardDealer(firstPlayer.deck, 3)
                val secondPlayer = game.players.retrieveOther(firstPlayer.username)
                val (secondPlayerDeck, secondPlayerCards) = cardDealer(secondPlayer.deck, 4)
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

    private fun createGame(pair: Pair<String, String>): Either<String, List<Event>> {
        return when (game) {
            NoGame -> Either.right(listOf(GameCreated(gameId, pair)))
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
                is TurnStarted -> this.copy(game = game.startTurn(event.player, event.playerDeck, event.playerHand))
                is DamageDealtWithCard -> this.copy(
                    game = game.dealingDamageWithCard(
                        event.cardUsed,
                        event.playerAttacking,
                        event.playerAttacked
                    )
                )
                is PlayerKilled -> this.copy(game = EndGame(game.players, event.playerKilled))
            }
            is EndGame -> this
        }
    }

    companion object {
        fun create(
            gameId: UUID,
            chooseFirstPlayer: (players: TwoPlayers) -> Player,
            cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>,
            events: List<Event>
        ) =
            events.fold(GameAggregate(gameId, chooseFirstPlayer, cardDealer)) { game, event -> game.evolve(event) }
    }

}