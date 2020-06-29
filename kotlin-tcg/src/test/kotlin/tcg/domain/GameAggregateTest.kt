package tcg.domain

import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.collections.shouldContain
import io.kotest.matchers.collections.shouldContainExactly
import io.kotest.matchers.shouldBe
import tcg.domain.Player.Companion.ORIGINAL_DECK
import tcg.infra.InMemoryEventStore
import java.util.*

class GameAggregateTest : StringSpec({
    lateinit var gameId: UUID
    lateinit var aggregate: GameAggregate
    lateinit var eventStore: EventStore

    beforeTest {
        gameId = UUID.randomUUID()
        eventStore = InMemoryEventStore()
        val game = Game(mapOf("A" to Player("A"), "B" to Player("B")))
        aggregate = GameAggregate(gameId, eventStore, game)
    }


    "players receive 3 cards" {

        val updated = aggregate
            .process(PlayerDrawCards(gameId, "A") { deck -> deck.take(3) })
            .process(PlayerDrawCards(gameId, "B") { deck -> deck.take(3) })

        val (deck, cards) = ORIGINAL_DECK.take(3)
        val hand = Hand(cards)
        eventStore.retrieveEvents(aggregate.id) shouldContainExactly listOf(
            CardDrawn(gameId, "A", deck, hand),
            CardDrawn(gameId, "B", deck, hand)
        )

        var player = updated.game.retrievePlayer("A")

        player.hand shouldBe hand
        player.deck shouldBe deck

        player = updated.game.retrievePlayer("B")

        player.hand shouldBe hand
        player.deck shouldBe deck
    }

    "set active player" {
        val updated = aggregate.process(SetActivePlayer(gameId) { players -> players.first().username })
        val activePlayer = aggregate.game.players().first()

        eventStore.retrieveEvents(aggregate.id) shouldContainExactly listOf(
            ActivePlayerSet(gameId, activePlayer.username)
        )
        updated.game.activePlayer shouldBe activePlayer.username
        updated.game.players() shouldContain activePlayer.increaseMana()
    }
})