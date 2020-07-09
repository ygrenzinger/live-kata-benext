import { BankAccount } from "../domain/BankAccount";
import { Console } from "console";
import { ConsoleStatementPrinter } from "../infrastructure/ConsoleStatementLine";

class BankAccountRepository {
    retrieve(uuid: string): BankAccount {
        return new BankAccount(uuid)
    }
}

const initBankAccountController = (app: any, bankAccountRepository: BankAccountRepository) => {
    app.get("/bank-account/:uuid/statement", (req: any, res: any) => {
        const bankAccount: BankAccount = bankAccountRepository.retrieve(req.uuid)
        //bankAccount.print(new ConsoleStatementPrinter())
        res.send("Hello world!");
    });

}