import { Money } from './Money';
import { IStatementPrinter, StatementLine } from './StatementPrinter';
import { Operation } from './Operation';

class BankAccount {
    id: string;
    operations: Operation[]

    constructor(id: string) {
        this.id = id;
    };

    public balance(): Money {
        return new Money(0);
    }

    public deposit(amount: Money, date: Date = new Date()) {
        return this;
    }
    public withdraw(amount: Money, date: Date = new Date()) {
        return this;
    }

    public buildStatementLines(): StatementLine[] {
        return [];
    }

}

export { BankAccount, Operation }