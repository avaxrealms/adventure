const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Attacher", function () {

    let attacher;
    let item = "\"Doom Tear\" Chain of Defence +1"

    before(async function () {

		_adv = await ethers.getContractFactory("Adventure");
		adv = await _adv.deploy();

		_attr = await ethers.getContractFactory("adventure_attributes");
		attr = await _attr.deploy(adv.address);

        _plunder = await ethers.getContractFactory("Plunder");
        plunder = await _plunder.deploy();

        _attacher = await ethers.getContractFactory("plunder_attacher");
        attacher = await _attacher.deploy(plunder.address, attr.address);
    });

    it("Should return length", async function () {
        expect(await attacher.length(item)).to.equal(0x1F);

    });

    it("Should return the last two characters", async function () {
        let item_length = await attacher.length(item);
        let bonus = await attacher.slice(item_length-1, item_length, item);
        expect(bonus).to.equal("+1");
    });

    it("Should return the first character", async function () {
        let item_length = await attacher.length(item);
        let bonus2 = await attacher.slice(1, 1, item);
        expect(bonus2).to.equal("\"");
    });

    it("Should return of in the item", async function () {
        let suffix = await attacher.containsSuffix (item)
        }
    )
});
