package tcg.infra

import tcg.domain.runner.InputRetriever

object ConsoleInputRetriever : InputRetriever {
    override fun retrieveInput(question: String?): String {
        question?.also { println(it) }
        return readLine()!!
    }
}