import { IStatementPrinter } from "../domain/StatementPrinter"

export class ConsoleStatementPrinter implements IStatementPrinter {
    printLine(line: string): void {
        throw new Error("Method not implemented.");
    }

}