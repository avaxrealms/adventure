const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Adventure contract", function () {
	let _adv;
	let adv;
	let level;

	before(async function () {
		_adv = await ethers.getContractFactory("Adventure");
		adv = await _adv.deploy();

		_rg = await ethers.getContractFactory("RealmGold");
		rg = await _rg.deploy(adv.address);

		await rg.deployed().then(async () => {
			await adv.setGoldContract(rg.address);
		});
	});

	it("Should summon an adventurer", async function () {
		await adv.summon(8).then(async () => {
			expect((await adv.summoner(0))[3]).to.equal(0x1);
		});
	});
});
