package tcg.domain

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContainExactly
import io.kotest.matchers.shouldBe
import tcg.domain.*
import tcg.domain.Player.Companion.ORIGINAL_DECK
import tcg.infra.InMemoryEventStore
import java.util.*

class GameAggregateTest : StringSpec({
    lateinit var gameId : UUID
    lateinit var game: GameAggregate
    lateinit var eventStore : EventStore

    beforeTest {
        gameId = UUID.randomUUID()
        eventStore = InMemoryEventStore()
        game = GameAggregate(gameId, eventStore, Pair(Player("A"), Player("B")))
    }

    "create game" {
        game.retrievePlayer("A") shouldBe Player("A")
        game.retrievePlayer("B") shouldBe Player("B")
    }

    "players receive 3 cards" {

        val updated = game.process(PlayerDrawCards(gameId, "A") { deck -> Pair(deck.take(3), deck.drop(3))})

        val hand = listOf(0, 0, 1).convert()
        eventStore.retrieveEvents(game.id) shouldContainExactly listOf(
            CardDrawn(gameId,"A", hand, ORIGINAL_DECK.drop(3))
        )

        val player = updated.retrievePlayer("A")!!

        player.hand shouldBe hand
        player.deck shouldBe ORIGINAL_DECK.drop(3)
    }

    "choose first player" {
        val player = game.retrievePlayer("A")!!
        val updated = game.process(ChooseFirstPlayer(gameId, player))

        eventStore.retrieveEvents(game.id) shouldContainExactly listOf(
            FirstPlayerChosen(gameId,player)
        )
        updated.currentPlayer shouldBe player
    }
})