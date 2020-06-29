package tcg.domain

data class Game(val players: Map<String, Player>, val activePlayer: String? = null) {
    init {
        require(players.size == 2)
    }

    fun players() = players.values

    fun retrievePlayer(username: String) = players[username]?: error("Unexpected Player")

    private fun updatePlayer(player: Player) =
        if (players.containsKey(player.username)) {
            this.copy(players = players + (player.username to player))
        } else {
            this
        }

    fun setActivePlayer(username: String) =
        this.updatePlayer(retrievePlayer(username).increaseMana()).copy(activePlayer = username)

    fun playerDrawCards(username: String, deck: Deck, hand: Hand) =
        this.updatePlayer(retrievePlayer(username).drawCards(deck, hand))

}