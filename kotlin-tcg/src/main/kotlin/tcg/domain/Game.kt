package tcg.domain

sealed class Game() {
    fun createGame(usernames: Pair<String, String>) =
        CreatingGame(Pair(Player(usernames.first), Player(usernames.second)))
}

object NoGame : Game()

data class CreatingGame(val players: TwoPlayers) : Game() {
    fun startGame(firstPlayer: String): RunnningGame {
        val first = players.retrieve(firstPlayer)
        return RunnningGame(players.updatePlayer(first.increaseMana(1)), firstPlayer)
    }
}

data class RunnningGame(val players: TwoPlayers, val activePlayer: String) : Game() {

    fun playerDrawCards(username: String, deck: Deck, hand: Hand) =
        this.updatePlayer(players.retrieve(username).drawCards(deck, hand))

    fun retrieveAndUpdate(username: String, updater: (Player) -> Player): RunnningGame {
        val player = players.retrieve(username)
        return updatePlayer(updater(player))
    }

    private fun updatePlayer(player: Player) =
        this.copy(players = players.updatePlayer(player))

}