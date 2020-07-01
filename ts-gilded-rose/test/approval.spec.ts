
import { Item, GildedRose } from '../app/gilded-rose';

require('approvals')
    .mocha();

describe('Gilded Rose', function () {
    it('golden master', function () {
        const items = [
            new Item("+5 Dexterity Vest", 10, 20), //
            new Item("Aged Brie", 0, 5), //
            new Item("Elixir of the Mongoose", 5, 7), //
            new Item("Sulfuras, Hand of Ragnaros", 0, 80), //
            new Item("Sulfuras, Hand of Ragnaros", -1, 80),
            new Item("Backstage passes to a TAFKAL80ETC concert", 15, 20),
            new Item("Backstage passes to a TAFKAL80ETC concert", 10, 30),
            new Item("Backstage passes to a TAFKAL80ETC concert", 5, 30)];

        const gildedRose = new GildedRose(items);

        for (let index = 0; index < 5; index++) {
            gildedRose.updateQuality();
        }
        const result = gildedRose.updateQuality();

        this.verifyAsJSON(result);
    });
});
