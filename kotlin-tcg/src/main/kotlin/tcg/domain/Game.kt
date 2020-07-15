package tcg.domain

sealed class Game()

object NoGame : Game() {
    fun createGame(usernames: Pair<String, String>) =
        CreatingGame(TwoPlayers(Player(usernames.first), Player(usernames.second)))
}

data class CreatingGame(val players: TwoPlayers) : Game() {
    fun startGame(event: GameStarted): RunnningGame {
        val first = players.retrieve(event.firstPlayer)
            .drawCards(event.firstPlayerDeck, event.firstPlayerHand)
        val second = players.retrieveOther(event.firstPlayer)
            .drawCards(event.secondPlayerDeck, event.secondPlayerHand)
        return RunnningGame(TwoPlayers(first, second), first.username)
    }
}

data class RunnningGame(val players: TwoPlayers, val activePlayer: String) : Game() {
    fun active() =
        players.retrieve(activePlayer)

    fun opponent() =
        players.retrieveOther(activePlayer)

    fun startTurn(activePlayer: String, playerDeck: Deck, playerHand: Hand): RunnningGame {
        val player = players.retrieve(activePlayer)
            .drawCards(playerDeck, playerHand)
            .increaseMana(1)
            .refillMana()
        return this.copy(players = players.updatePlayer(player), activePlayer = activePlayer)
    }

    fun dealingDamageWithCard(card: Card, playerAttacking: String, playerAttacked: String): RunnningGame {
        val attacked = players.retrieve(playerAttacked).loosingHealth(card())
        val attacking = players.retrieve(playerAttacking)
            .loosingMana(card())
            .usingCard(card)
        val updatePlayers = players
            .updatePlayer(attacked)
            .updatePlayer(attacking)
        return this.copy(players = updatePlayers)
    }

    fun playerBleed(bleedingPlayer: String): RunnningGame {
        val player =  players.retrieve(bleedingPlayer).loosingHealth(1)
        return this.copy(players = players.updatePlayer(player))
    }

}

data class EndGame(val players: TwoPlayers, val killed: String) : Game()