const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Adventure", function () {
  let _adv;
  let adv;
  let level;

  before(async function () {
    _adv = await ethers.getContractFactory("Adventure");
    adv = await _adv.deploy();

    _rg = await ethers.getContractFactory("RealmGold");
    rg = await _rg.deploy(adv.address);

    _attr = await ethers.getContractFactory("adventure_attributes");
    attr = await _attr.deploy(adv.address);

    _craft_m = await ethers.getContractFactory("adventure_crafting_materials");
    craft_m = await _craft_m.deploy(adv.address, attr.address);

    _sd = await ethers.getContractFactory("adventure_dungeon_snowbridge");
    sd = await _sd.deploy(adv.address, attr.address, craft_m.address);

    await rg.deployed().then(async () => {
      await adv.setGoldContract(rg.address);
    });

    await sd.deployed().then(async () => {
      await craft_m.grantRole(
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MINTER_CONTRACT")),
        sd.address
      );
      await adv.grantRole(
        ethers.utils.keccak256(ethers.utils.toUtf8Bytes("MANAGING_CONTRACT")),
        sd.address
      );
    });
  });

  it("Should summon an adventurer", async function () {
    await adv.summon(8).then(async () => {
      await adv.adventure(0);
      await adv.level_up(0);
      await adv.level_up(0);
      await adv.level_up(0);
      expect((await adv.summoner(0))[3]).to.equal(0x4);
    });
  });

  it("Should increase attributes and adventure", async function () {
    await attr.point_buy(0, 8, 18, 15, 8, 15, 8).then(async () => {
      await sd.adventure(0);
    });
  });

  it("Should have a balance of 1 Craft (I)", async function () {
    expect(await craft_m.balanceOf(0)).to.equal(0x1);
  });
});
