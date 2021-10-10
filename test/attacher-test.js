const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Attacher", function () {

    let attacher;
    let item = "Doom Tear Chain of Defence +1"

    before(async function () {
        _plunder = await ethers.getContractFactory("Plunder");
        plunder = await _plunder.deploy();

        _attacher = await ethers.getContractFactory("plunder_attacher");
        attacher = await _attacher.deploy(plunder.address);
    });

    it("Should return length", async function () {
        expect(await attacher.length(item)).to.equal(0x1D);

    });

    it("Should return the last two characters", async function () {
        let item_length = await attacher.length(item);
        let bonus = await attacher.slice(item_length-1, item_length, item);
        expect(bonus).to.equal("+1");
    });
});
