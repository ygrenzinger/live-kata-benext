import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainExactlyInAnyOrder
import io.kotest.matchers.shouldBe
import tcg.domain.core.Player

class PlayerTest : StringSpec({
    lateinit var player: Player

    beforeTest {
        player = Player("test")
    }

    "Player start with 30 health and 0 mana" {
        player.health shouldBe 30
        player.totalManaSlot shouldBe 0
    }

    "Player starts with a deck of 20 damage cards" {
        player.deck() shouldContainExactlyInAnyOrder Player.ORIGINAL_DECK.invoke()
    }

})
