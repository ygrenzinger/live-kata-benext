package tcg.domain.core

data class Player(
    val username: String,
    val health: Int = 30,
    val totalManaSlot: Int = 0,
    val filledManaSlot: Int = 0,
    val deck: Deck = ORIGINAL_DECK,
    val hand: Hand = Hand(emptyList())
) {

    fun drawCards(deck: Deck, hand: Hand) = this.copy(deck = deck, hand = hand)
    fun usingCard(card: Card) = this.copy(hand = hand - card)
    fun loosingHealth(value: Int) = this.copy(health = health - value)
    fun increaseMana(value: Int): Player =
        this.copy(totalManaSlot = totalManaSlot + value, filledManaSlot = filledManaSlot + value)

    fun loosingMana(value: Int) = this.copy(filledManaSlot = filledManaSlot - value)
    fun refillMana(): Player = this.copy(filledManaSlot = totalManaSlot)

    fun describe() =
        "Player $username - Health $health/30 - Mana $filledManaSlot/$totalManaSlot - Hand ${hand.describe()} - Deck ${deck.describe()}"

    companion object {
        val ORIGINAL_DECK = Deck(
            listOf(
                0,
                0,
                1,
                1,
                2,
                2,
                2,
                3,
                3,
                3,
                3,
                4,
                4,
                4,
                5,
                5,
                6,
                6,
                7,
                8
            ).convert()
        )
    }
}