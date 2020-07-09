export class Money {
    readonly value: number;
    constructor(value: number) {
        this.value = value;
    };

    public add(money: Money) {
        return new Money(this.value + money.value);
    }

    public sub(money: Money) {
        return new Money(this.value - money.value);
    }
}