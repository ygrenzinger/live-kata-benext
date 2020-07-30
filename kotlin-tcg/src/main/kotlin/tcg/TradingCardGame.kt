package tcg

import arrow.core.getOrElse
import tcg.domain.core.Card
import tcg.domain.core.Deck
import tcg.domain.runner.GameRunner
import tcg.infra.ConsoleInputRetriever
import tcg.infra.ConsoleGamePrinter
import tcg.infra.InMemoryEventStore
import java.util.*
import kotlin.random.Random

fun randomCardDealer(deck: Deck, i: Int, acc: List<Card>): Pair<Deck, List<Card>> {
    return if (i == 0) {
        Pair(deck, acc)
    } else {
        val cardAtIndex = Random.nextInt(deck().size)
        val card = deck()[cardAtIndex]
        val newDeck = deck.removeCard(card).getOrElse { deck }
        randomCardDealer(newDeck, i - 1, acc + card)
    }
}

fun main() {
    val runner = GameRunner(
        UUID.randomUUID(),
        ConsoleInputRetriever,
        ConsoleGamePrinter,
        InMemoryEventStore(),
        chooseFirstPlayer = {
                players -> if (Random.nextBoolean())  { players.first }  else { players.second }
        },
        cardDealer = {
            deck, i -> randomCardDealer(deck, i, emptyList())
        }
    )

    runner.play()
}