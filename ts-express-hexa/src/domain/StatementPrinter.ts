import { Money } from "./Money";

interface StatementLine {
    date: Date
    amount: number
    balance: number
}

const formatStatementLine = (statementLine: StatementLine): string => {
    return ''
}


interface IStatementPrinter {
    printLine(line: string): void
}

export { IStatementPrinter, StatementLine }