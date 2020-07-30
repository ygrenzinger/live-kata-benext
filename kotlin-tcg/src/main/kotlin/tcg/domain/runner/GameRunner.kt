package tcg.domain.runner

import arrow.core.Either
import arrow.core.flatMap
import arrow.core.getOrHandle
import tcg.domain.core.*
import java.util.*

class GameRunner(
    private val gameId: UUID,
    private val inputRetriever: InputRetriever,
    private val gamePrinter: GamePrinter,
    private val eventStore: EventStore,
    private val chooseFirstPlayer: (players: TwoPlayers) -> Player,
    private val cardDealer: (Deck, Int) -> Pair<Deck, List<Card>>
) {
    private var gameAggregate = GameAggregate.create(gameId, chooseFirstPlayer, cardDealer)

    init {
        eventStore.addProjection(HistoryProjection())
    }

    fun play() {
        var input = retrieveUserCommand()
        while (input != "exit") {
            gamePrinter.clear()
            gameAggregate = interpret(input).flatMap {
                applyCommands(gameAggregate, it)
            }.getOrHandle {
                gamePrinter.print("Error  : $it")
                gameAggregate
            }
            gamePrinter.print("Game history")
            eventStore.get(HistoryProjection.NAME)?.printOn(gamePrinter)
            gamePrinter.print("Game state")
            gameAggregate.gameState.printOn(gamePrinter)
            input = retrieveUserCommand()
        }
    }

    private fun retrieveUserCommand() =
        inputRetriever.retrieveInput("What do you want to do ? 'create' 'next' 'attack X' 'exit'")

    private fun applyCommands(gameAggregate: GameAggregate, commands: List<Command>): Either<String, GameAggregate> {
        val initial = applyCommand(gameAggregate, commands.first())
        return commands.drop(1).fold(initial) { acc, command -> acc.flatMap { applyCommand(it, command) } }
    }

    private fun applyCommand(gameAggregate: GameAggregate, command: Command): Either<String, GameAggregate> {
        val handle = gameAggregate.handle(command)
        return handle.flatMap {
            eventStore.storeAndRetrieveEvents(gameId, it)
        }.map {
            GameAggregate.create(gameId, chooseFirstPlayer, cardDealer, it)
        }
    }

    private fun interpret(input: String): Either<String, List<Command>> {
        return when {
            input == "create" -> {
                val playerA = inputRetriever.retrieveInput("first player name ?")
                val playerB = inputRetriever.retrieveInput("second player name ?")
                Either.right(listOf(
                    CreateGame(gameId, Pair(playerA, playerB)),
                    StartGame(gameId),
                    FirstTurn(gameId)
                ))
            }
            input == "next" -> {
                Either.right(listOf(
                    SwitchPlayer(gameId)
                ))
            }
            input.startsWith("attack") -> {
                val value = Integer.parseInt(input.last().toString())
                Either.right(listOf(
                    DealDamageWithCard(gameId, Card(value))
                ))
            }
            else -> {
                Either.left("Unknown input : $input")
            }
        }
    }

}
