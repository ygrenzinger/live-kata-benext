import { expect } from "chai";
import { v1 as uuidV1 } from "uuid";
import { BankAccount } from "../../src/domain/BankAccount";
import { Money } from "../../src/domain/Money";
import { IStatementPrinter } from "../../src/domain/StatementPrinter";


class FakeStatementPrinter implements IStatementPrinter {
    lines: String[] = []
    printLine(line: string): void {
        this.lines.push(line);
    }

}

describe('Bank account', () => {
    it('should make a deposit', () => {
        const bankAccount = new BankAccount(uuidV1());
        bankAccount.deposit(new Money(1000));
        expect(bankAccount.balance).to.deep.equal(new Money(1000));
    });

    it('should make a withdraw', () => {
        const bankAccount = new BankAccount(uuidV1())
            .deposit(new Money(1000))
            .withdraw(new Money(500));
        expect(bankAccount.balance).to.deep.equal(new Money(500));
    });

    it('should display statement', () => {
        const bankAccount = new BankAccount(uuidV1())
            .deposit(new Money(1000), new Date(2020, 1, 12))
            .deposit(new Money(2000), new Date(2020, 1, 13))
            .withdraw(new Money(500), new Date(2020, 2, 8));

        expect(bankAccount.buildStatementLines()).to.equal([
            { date: new Date(2020, 2, 8), amount: -500, balance: 2500 },
            { date: new Date(2020, 1, 13), amount: -2000, balance: 3000 },
            { date: new Date(2020, 1, 12), amount: -1000, balance: 1000 }
        ])

    });
});
