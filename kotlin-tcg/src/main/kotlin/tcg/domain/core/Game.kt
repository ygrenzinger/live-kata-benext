package tcg.domain.core

import tcg.domain.runner.GamePrinter
import tcg.domain.runner.Projection

sealed class Game() : Projection {
    override val name: String = "game state projection"

    override fun evolve(event: Event): Game {
        return when (this) {
            is NoGame -> when (event) {
                is GameCreated -> createGame(event.usernames)
                else -> this
            }
            is CreatingGame -> when (event) {
                is GameStarted -> startGame(event)
                else -> this
            }
            is RunningGame -> when (event) {
                is GameCreated -> this
                is GameStarted -> this
                is TurnStarted -> startTurn(event.player, event.playerDeck, event.playerHand)
                is DamageDealtWithCard -> dealingDamageWithCard(event.card, event.playerAttacking, event.playerAttacked)
                is PlayerKilled -> EndGame(players, event.playerKilled)
                is PlayerBleed -> playerBleed(event.player)
                is PlayerBleedToDeath -> EndGame(players, event.playerKilled)
            }
            is EndGame -> this
        }
    }
}

object NoGame : Game() {
    fun createGame(usernames: Pair<String, String>) =
        CreatingGame(
            TwoPlayers(
                Player(usernames.first),
                Player(usernames.second)
            )
        )

    override fun printOn(gamePrinter: GamePrinter) {
        gamePrinter.print("Waiting for players")
    }
}

data class CreatingGame(val players: TwoPlayers) : Game() {
    fun startGame(event: GameStarted): RunningGame {
        val first = players.retrieve(event.firstPlayer)
            .drawCards(event.firstPlayerDeck, event.firstPlayerHand)
        val second = players.retrieveOther(event.firstPlayer)
            .drawCards(event.secondPlayerDeck, event.secondPlayerHand)
        return RunningGame(TwoPlayers(first, second), first.username)
    }

    override fun printOn(gamePrinter: GamePrinter) {
        gamePrinter.print("Players ${players.first.username} and ${players.second.username} waiting")
    }
}

data class RunningGame(val players: TwoPlayers, val activePlayer: String) : Game() {
    fun active() =
        players.retrieve(activePlayer)

    fun opponent() =
        players.retrieveOther(activePlayer)

    fun startTurn(activePlayer: String, playerDeck: Deck, playerHand: Hand): RunningGame {
        val player = players.retrieve(activePlayer)
            .drawCards(playerDeck, playerHand)
            .increaseMana(1)
            .refillMana()
        return this.copy(players = players.updatePlayer(player), activePlayer = activePlayer)
    }

    fun dealingDamageWithCard(card: Card, playerAttacking: String, playerAttacked: String): RunningGame {
        val attacked = players.retrieve(playerAttacked).loosingHealth(card())
        val attacking = players.retrieve(playerAttacking)
            .loosingMana(card())
            .usingCard(card)
        val updatePlayers = players
            .updatePlayer(attacked)
            .updatePlayer(attacking)
        return this.copy(players = updatePlayers)
    }

    fun playerBleed(bleedingPlayer: String): RunningGame {
        val player = players.retrieve(bleedingPlayer).loosingHealth(1)
        return this.copy(players = players.updatePlayer(player))
    }

    override fun printOn(gamePrinter: GamePrinter) {
        gamePrinter.print(describePlayer(players.first))
        gamePrinter.print(describePlayer(players.second))
    }

    private fun describePlayer(player: Player) =
        if (activePlayer == player.username) {
            "active : " + player.describe()
        } else {
            player.describe()
        }

}

data class EndGame(val players: TwoPlayers, val killed: String) : Game() {

    override fun printOn(gamePrinter: GamePrinter) {
        gamePrinter.print(describePlayer(players.first))
        gamePrinter.print(describePlayer(players.second))
    }

    private fun describePlayer(player: Player) =
        if (killed == player.username) {
            "dead : " + player.describe()
        } else {
            "winner : " + player.describe()
        }
}
