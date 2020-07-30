package tcg.domain.runner

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainInOrder
import tcg.domain.core.Player
import tcg.infra.InMemoryEventStore
import java.util.*

class GameRunnerTest : StringSpec({

    "creating game" {
        val inputRetriever = FakeInputRetriever()
        val gamePrinter = FakeGamePrinter()
        creatingGame(inputRetriever)
        val runner = GameRunner(
            UUID.randomUUID(),
            inputRetriever,
            gamePrinter,
            InMemoryEventStore(),
            { players -> players.first },
            { deck, n -> deck.take(n) })
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

    "Second player dealing 1 damage" {
        val inputRetriever = FakeInputRetriever()
        val gamePrinter = FakeGamePrinter()
        creatingGame(inputRetriever)
        inputRetriever.addInput("next")
        inputRetriever.addInput("attack 1")
        val runner = GameRunner(
            UUID.randomUUID(),
            inputRetriever,
            gamePrinter,
            InMemoryEventStore(),
            { players -> players.first },
            { deck, n -> deck.take(n) })
        runner.play()
        val expectedLines = listOf(
            "Active player is now B",
            "Player B dealing 1 damage",
            "Game state",
            "Player A - Health 29/30 - Mana 1/1 - Hand (0,0,1,1) - Deck (2,2,2,3,3,3,3,4,4,4,5,5,6,6,7,8)",
            "active : Player B - Health 30/30 - Mana 0/1 - Hand (0,0,1,2) - Deck (2,2,3,3,3,3,4,4,4,5,5,6,6,7,8)"
        )
        gamePrinter.lines() shouldContainInOrder expectedLines
    }

    "First player killing second player" {
        val inputRetriever = FakeInputRetriever()
        val gamePrinter = FakeGamePrinter()
        creatingGame(inputRetriever)
        killingPlayer(inputRetriever)
        val runner = GameRunner(
            UUID.randomUUID(),
            inputRetriever,
            gamePrinter,
            InMemoryEventStore(),
            { players -> players.first },
            { deck, n -> deck.take(n) })
        runner.play()
        val expectedLines = listOf(
            "Player A dealing 4 damage",
            "Player B has been killed",
            "Game state",
            "winner : Player A - Health 30/30 - Mana 8/12 - Hand (0,0,5) - Deck (5,6,6,7,8)",
            "dead : Player B - Health -2/30 - Mana 11/11 - Hand (0,0,1,1,2) - Deck (5,6,6,7,8)"
        )
        gamePrinter.lines() shouldContainInOrder expectedLines
    }
})

private fun killingPlayer(inputRetriever: FakeInputRetriever) {
    var totalDamage = 0
    var deck = Player.ORIGINAL_DECK().drop(2)
    while (totalDamage < 30) {
        val card = deck.first()
        inputRetriever.addInput("attack ${card()}")
        deck = deck.drop(1)
        totalDamage += card()
        inputRetriever.addInput("next")
        inputRetriever.addInput("next")
    }
}

private fun creatingGame(inputRetriever: FakeInputRetriever) {
    inputRetriever.addInput("create")
    inputRetriever.addInput("A")
    inputRetriever.addInput("B")
}

class FakeGamePrinter : GamePrinter {

    private var lines: MutableList<String> = mutableListOf()

    override fun print(line: String) {
        this.lines.add(line)
    }

    override fun clear() {
        lines.clear()
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
