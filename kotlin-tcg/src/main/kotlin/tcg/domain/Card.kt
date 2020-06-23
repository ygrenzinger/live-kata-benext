package tcg.domain

data class Card(val value: Int)

fun List<Int>.convert() = this.map(::Card)
