package tcg.domain

data class Player(val health: Int = 30, val mana: Int = 0, val deck: List<Int> = listOf(0,0,1,1,2,2,2,3,3,3,3,4,4,4,5,5,6,6,7,8), val hand: List<Int> = listOf()) {

    fun drawHand(): Player {
        return this.copy(deck = deck.drop(3), hand = deck.take(3))
    }
}
