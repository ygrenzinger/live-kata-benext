package tcg.infra

import tcg.domain.runner.GamePrinter

object ConsoleGamePrinter : GamePrinter {
    override fun print(line: String) {
        println(line)
    }

    override fun clear() {
        print("\u001b[H\u001b[2J")
    }

}