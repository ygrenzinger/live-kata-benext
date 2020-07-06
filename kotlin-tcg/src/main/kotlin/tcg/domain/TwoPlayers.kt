package tcg.domain

typealias TwoPlayers = Pair<Player, Player>

fun TwoPlayers.retrieve(username: String) = when {
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

fun TwoPlayers.retrieveOther(username: String) = when {
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

fun TwoPlayers.updatePlayer(player: Player) = when {
    first.username == player.username -> {
        Pair(player, second)
    }
    second.username == player.username -> {
        Pair(first, player)
    }
    else -> {
        this
    }
}

fun TwoPlayers.players() = setOf(first, second)