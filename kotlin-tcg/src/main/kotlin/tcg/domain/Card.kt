@file:Suppress("EXPERIMENTAL_FEATURE_WARNING")

package tcg.domain

data class Card(val value: Int)

inline class Deck(private val cards: List<Card>) {
    operator fun invoke() = cards
    operator fun minus(cards: List<Card>) = Deck(this.cards - cards)
    fun take(n: Int) = Pair(Deck(cards.drop(n)), cards.take(n))
}

inline class Hand(private val cards: List<Card>) {
    operator fun plus(cards: List<Card>) = Hand(this.cards + cards)
}

fun List<Int>.convert() = this.map(::Card)
