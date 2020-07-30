package tcg.domain.core

data class TwoPlayers(val first: Player, val second: Player) {

    fun retrieve(username: String) = when {
        first.username == username -> {
            first
        }
        second.username == username -> {
            second
        }
        else -> {
            error("Unexpected Player")
        }
    }

    fun retrieveOther(username: String) = when {
        first.username == username -> {
            second
        }
        second.username == username -> {
            first
        }
        else -> {
            error("Unexpected Player")
        }
    }

    fun updatePlayer(player: Player) = when {
        first.username == player.username -> {
            TwoPlayers(player, second)
        }
        second.username == player.username -> {
            TwoPlayers(first, player)
        }
        else -> {
            this
        }
    }
}
