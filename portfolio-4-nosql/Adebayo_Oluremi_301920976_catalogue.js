const products = db.getSiblingDB("temu_portfolio").catalogue;
products.createIndex({category: 1, priceNgn: 1});
const cards = [
  { _id: 1, name: "iPhone 18", category: "Electronics", priceNgn: 450000,
    attributes: { colour: "Blue", storageGb: 256 } },
  { _id: 2, name: "Portable power bank", category: "Electronics", priceNgn: 8500,
    attributes: { batteryCapacityMah: 10000, connector: "Universal Serial Bus" } }
];
for (const card of cards) {
  printjson(products.replaceOne({_id: card._id}, card, {upsert: true}));
}
const electronics = products.find({category: "Electronics", priceNgn: {$gte: 400000, $lte: 500000}}).toArray();
const powerBank = products.findOne({_id: 2});
if (electronics.length !== 1 || electronics[0]._id !== 1 || electronics[0].attributes.storageGb !== 256 ||
    powerBank?.attributes.batteryCapacityMah !== 10000) {
  throw new Error("Unexpected catalogue result");
}
print("PASS: electronics search returned the iPhone 18 and the power bank kept its own fields");
printjson(electronics);
printjson(powerBank);
