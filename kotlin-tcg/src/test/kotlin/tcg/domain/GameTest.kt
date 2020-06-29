package tcg.domain

import io.kotest.assertions.throwables.shouldThrowAny
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe

class GameTest : StringSpec({

    "create game" {

        val game = Game(mapOf("A" to Player("A"), "B" to Player("B")))
        game.retrievePlayer("A") shouldBe Player("A")
        game.retrievePlayer("B") shouldBe Player("B")
    }

    "game should have exactly 2 players" {
        shouldThrowAny {
            Game(mapOf("A" to Player("A"), "B" to Player("B"), "C" to Player("C")))
        }
    }
})