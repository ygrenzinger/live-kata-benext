package tcg.domain

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainInOrder
import tcg.domain.runner.GamePrinter
import tcg.domain.runner.InputRetriever
import tcg.domain.runner.GameRunner
import tcg.infra.InMemoryEventStore
import java.util.*

class GameRunnerTest : StringSpec({

    "creating game" {
        val inputRetriever = FakeInputRetriever()
        val gamePrinter = FakeGamePrinter()
        inputRetriever.addInput("create")
        inputRetriever.addInput("A")
        inputRetriever.addInput("B")
        val runner = GameRunner(UUID.randomUUID(), inputRetriever, gamePrinter, InMemoryEventStore(), { players -> players.first }, { deck, n -> deck.take(n) })
        runner.play()
        val expectedLines = listOf(
            "Game history",
            "Game created with players A and B",
            "Game started with A as first active player",
            "Active player is now A",
            "Game state",
            "active : Player A - Health 30/30 - Mana 1/1 - Hand (0,0,1,1) - Deck (2,2,2,3,3,3,3,4,4,4,5,5,6,6,7,8)",
            "Player B - Health 30/30 - Mana 0/0 - Hand (0,0,1,1) - Deck (2,2,2,3,3,3,3,4,4,4,5,5,6,6,7,8)"
        )
        gamePrinter.lines() shouldContainInOrder expectedLines
    }
})

class FakeGamePrinter : GamePrinter {

    private var lines: MutableList<String> = mutableListOf()

    override fun print(line: String) {
        this.lines.add(line)
    }

    fun lines() = lines
}

class FakeInputRetriever : InputRetriever {

    private val list: MutableList<String> = mutableListOf()

    fun addInput(command: String) {
        list.add(command)
    }

    @ExperimentalStdlibApi
    override fun retrieveInput(question: String?): String {
        if (list.isEmpty()) {
            return "exit"
        }
        return list.removeFirst()
    }

}