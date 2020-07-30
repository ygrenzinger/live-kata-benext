package tcg.domain.core

import arrow.core.Either
import java.util.*

data class GameAggregate(
    val gameId: UUID,
    val chooseFirstPlayer: (players: TwoPlayers) -> Player,
    val cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>,
    val gameState: Game = NoGame
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

    private fun evolve(event: Event) = this.copy(gameState = gameState.evolve(event))

    private fun dealDamage(card: Card): Either<String, List<Event>> {
        return when (gameState) {
            is RunningGame -> {
                return when {
                    gameState.active().filledManaSlot < card() -> {
                        Either.left("not enough mana to play card ${card()}")
                    }
                    card !in gameState.active().hand -> {
                        Either.left("card ${card()} is not in hand")
                    }
                    else -> {
                        val events = mutableListOf<Event>(
                            DamageDealtWithCard(
                                gameId,
                                card,
                                gameState.active().username,
                                gameState.opponent().username
                            )
                        )
                        if (gameState.opponent().health - card() <= 0) {
                            events.add(
                                PlayerKilled(
                                    gameId,
                                    gameState.opponent().username
                                )
                            )
                        }
                        Either.right(events)
                    }
                }
            }
            else -> Either.left("wrong game state")
        }
    }

    private fun startTurn(): Either<String, List<Event>> {
        return when (gameState) {
            is RunningGame -> startTurn(gameState.active())
            else -> Either.left("wrong game state")
        }
    }

    private fun switchPlayer(): Either<String, List<Event>> {
        return when (gameState) {
            is RunningGame -> startTurn(gameState.opponent())
            else -> Either.left("wrong game state")
        }
    }

    private fun startTurn(player: Player): Either<String, List<Event>> {
        return Either.right(
            when {
                player.health == 0 -> {
                    listOf(PlayerBleedToDeath(gameId, player.username))
                }
                player.deck.isEmpty() -> {
                    listOf(
                        PlayerBleed(gameId, player.username),
                        TurnStarted(
                            gameId,
                            player.username,
                            player.deck,
                            player.hand
                        )
                    )
                }
                else -> {
                    val (deck, cards) = cardDealer(player.deck, 1)
                    val hand = if (player.hand().size < 5) {
                        player.hand.plus(cards)
                    } else {
                        player.hand
                    }
                    listOf(TurnStarted(gameId, player.username, deck, hand))
                }
            }
        )
    }

    private fun startGame(): Either<String, List<Event>> {
        return when (gameState) {
            is CreatingGame -> {
                val firstPlayer = chooseFirstPlayer(gameState.players)
                val (firstPlayerDeck, firstPlayerCards) = cardDealer(firstPlayer.deck, 3)
                val secondPlayer = gameState.players.retrieveOther(firstPlayer.username)
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
        return when (gameState) {
            NoGame -> Either.right(listOf(GameCreated(gameId, pair)))
            else -> Either.left("wrong game state")
        }
    }

    companion object {
        fun create(
            gameId: UUID,
            chooseFirstPlayer: (players: TwoPlayers) -> Player,
            cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>,
            events: List<Event> = emptyList()
        ) =
            events.fold(GameAggregate(gameId, chooseFirstPlayer, cardDealer))
            { aggregate, event -> aggregate.evolve(event) }
    }

}