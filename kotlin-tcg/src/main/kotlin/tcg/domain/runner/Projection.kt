package tcg.domain.runner

import tcg.domain.core.Event

interface Projection {
    val name: String
    fun evolve(event: Event): Projection
    fun printOn(gamePrinter: GamePrinter)
}