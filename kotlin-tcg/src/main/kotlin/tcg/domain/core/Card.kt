@file:Suppress("EXPERIMENTAL_FEATURE_WARNING")

package tcg.domain.core

import arrow.core.Option

data class Card(private val value: Int) {
    operator fun invoke() = value
    override fun toString() = value.toString()
}

inline class Deck(private val cards: List<Card>) {
    operator fun invoke() = cards
    operator fun minus(cards: List<Card>) =
        Deck(this.cards - cards)
    fun isEmpty() = cards.isEmpty()
    fun take(n: Int): Pair<Deck, List<Card>> = Pair(Deck(cards.drop(n)), cards.take(n))
    fun removeCard(card: Card): Option<Deck> {
        val index = cards.indexOf(card)
        return if (index == -1) {
            Option.empty()
        } else {
            Option.just(Deck(cards.take(index) + cards.drop(index+1)))
        }
    }
    fun describe() = cards.describe()
}

inline class Hand(private val cards: List<Card>) {
    operator fun invoke() = cards
    operator fun plus(cards: List<Card>) =
        Hand(this.cards + cards)
    operator fun minus(card: Card) =
        Hand(this.cards - card)
    operator fun contains(card: Card) = card in this.cards
    fun describe() = cards.describe()

}

fun List<Card>.describe() = "(${this.joinToString(",")})"
fun List<Int>.convert() = this.map(::Card)
