package tcg.domain

data class Player(val username: String,
                  val health: Int = 30,
                  val mana: Int = 0,
                  val deck: List<Card> = ORIGINAL_DECK,
                  val hand: List<Card> = emptyList()
) {

    companion object {
        val ORIGINAL_DECK = listOf(0,0,1,1,2,2,2,3,3,3,3,4,4,4,5,5,6,6,7,8).convert()
    }
}