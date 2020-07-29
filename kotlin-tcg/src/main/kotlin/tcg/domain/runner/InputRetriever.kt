package tcg.domain.runner

interface InputRetriever {
    fun retrieveInput(question: String? = null): String
}