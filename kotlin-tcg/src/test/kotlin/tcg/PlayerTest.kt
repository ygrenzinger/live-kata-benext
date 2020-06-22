import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainAnyOf
import io.kotest.matchers.collections.shouldContainExactlyInAnyOrder
import io.kotest.matchers.shouldBe
import tcg.Player

class PlayerTest : StringSpec({
  lateinit var player: Player

  beforeTest {
    player = Player()
  }

  "Player start with 30 health and 0 mana" {
    player.health shouldBe 30
    player.mana shouldBe 0
  }

  "Player starts with a deck of 20 damage cards" {
    player.deck shouldContainExactlyInAnyOrder listOf(0, 0, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 8)
  }

  "Player should draw 3 cards from his deck in his hand" {
    val originalDeck = player.deck
    player = player.drawHand()
    player.deck.size shouldBe 17
    player.hand.size shouldBe 3
    player.hand shouldContainAnyOf originalDeck
  }
})
