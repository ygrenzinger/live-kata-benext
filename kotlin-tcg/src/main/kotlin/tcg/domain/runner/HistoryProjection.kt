package tcg.domain.runner

import tcg.domain.core.*

data class HistoryProjection(val lines: List<String> = emptyList()) : Projection {

    override val name: String = NAME

    override fun evolve(event: Event): Projection {
        val line = when (event) {
            is GameCreated -> "Game created with players ${event.usernames.first} and ${event.usernames.second}"
            is GameStarted -> "Game started with ${event.firstPlayer} as first active player"
            is TurnStarted -> "Active player is now ${event.player}"
            is DamageDealtWithCard -> "Player ${event.playerAttacking} dealing ${event.card()} damage"
            is PlayerKilled -> "Player ${event.playerKilled} has been killed"
            is PlayerBleed -> TODO()
            is PlayerBleedToDeath -> TODO()
            else -> ""
        }
        return HistoryProjection(lines + line)
    }

    override fun printOn(gamePrinter: GamePrinter) {
        lines.forEach {
            gamePrinter.print(it)
        }
    }

    companion object {
        const val NAME = "history projection"
    }

}