package tcg.domain

data class Player(val username: String,
                  val health: Int = 30,
                  val mana: Int = 0,
                  val deck: Deck = ORIGINAL_DECK,
                  val hand: Hand = Hand(emptyList())
) {

    fun increaseMana(value: Int) : Player = this.copy(mana = mana + value)

    fun drawCards(deck: Deck, hand: Hand) = this.copy(deck = deck, hand = hand)

    companion object {
        val ORIGINAL_DECK = Deck(listOf(0,0,1,1,2,2,2,3,3,3,3,4,4,4,5,5,6,6,7,8).convert())
    }
}