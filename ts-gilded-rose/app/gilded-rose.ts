export class Item {
    name: itemNames;
    sellIn: number;
    quality: number;

    constructor(name: itemNames, sellIn: number, quality: number) {
        this.name = name;
        this.sellIn = sellIn;
        this.quality = quality;
    }

    increaseQuality() {
        this.quality += 1;
    }

    decreaseQuality() {
        this.quality -= 1;
    }

    resetQuality() {
        this.quality = 0;
    }

    decreaseSellIn() {
        this.sellIn -= 1;
    }

    updateQuality() {
        switch (this.name) {
            case itemsNames.SULFURAS:
                break;
            case itemsNames.BRIE:
                if (this.quality < 50) {
                    this.increaseQuality();
                }

                this.decreaseSellIn();

                if (this.sellIn < 0 && this.quality < 50) {
                    this.increaseQuality();
                }
                break;
            case itemsNames.CONCERT:
                if (this.quality < 50) {
                    this.increaseQuality();
                    if (this.quality < 50) {
                        if (this.sellIn < 11) {
                            this.increaseQuality();
                        }
                        if (this.sellIn < 6) {
                            this.increaseQuality();
                        }
                    }
                }

                this.decreaseSellIn();

                if (this.sellIn < 0) {
                    this.resetQuality();
                }
                break;

            default:
                if (this.quality > 0) {
                    this.decreaseQuality();
                }

                this.decreaseSellIn();

                if (this.sellIn < 0 && this.quality > 0) {
                    this.decreaseQuality();
                }
                break;
        }
    }
}

type itemNames = "+5 Dexterity Vest" | "Aged Brie" | "Elixir of the Mongoose" | "Sulfuras, Hand of Ragnaros" | "Backstage passes to a TAFKAL80ETC concert";

enum itemsNames {
    VEST = "+5 Dexterity Vest",
    BRIE = "Aged Brie",
    ELIXIR = "Elixir of the Mongoose",
    SULFURAS = "Sulfuras, Hand of Ragnaros",
    CONCERT = "Backstage passes to a TAFKAL80ETC concert"
}

export class GildedRose {
    items: Array<Item>;

    constructor(items = [] as Array<Item>) {
        this.items = items;
    }

    updateQuality(): Item[] {
        this.items.forEach(item => {
            item.updateQuality()
        });

        return this.items;
    }
}
