const { expect } = require("chai");
const { ethers } = require("hardhat");
const { uriToImage } = require("./testutil");

// This is a hack to import terminal-image because the author
// is a douchebag who wont provide commonJS compatibility.
let terminalImage;
(async () => {
  terminalImage = (await import("terminal-image")).default;
})();

async function mineBlocks(seconds) {
  await network.provider.send("evm_increaseTime", [seconds]);
  await network.provider.send("evm_mine")
}

describe("Adventure", function () {
  let _adv;
  let adv;
  let level;
  let test_runs = 1;
  let accounts;

  beforeEach(async function () {

    accounts = await hre.ethers.getSigners();

    _adv = await ethers.getContractFactory("Adventure");
    adv = await _adv.deploy();

    _plunder = await ethers.getContractFactory("Plunder");
    plunder = await _plunder.deploy();

    _rg = await ethers.getContractFactory("RealmGold");
    rg = await _rg.deploy(adv.address, plunder.address);

    await rg.deployed().then(async () => {
      await adv.setGoldContract(rg.address);
    });

    _attr = await ethers.getContractFactory("adventure_attributes");
    attr = await _attr.deploy(adv.address);

    _craft_m = await ethers.getContractFactory("adventure_crafting_materials");
    craft_m = await _craft_m.deploy(adv.address, attr.address);

    _sd = await ethers.getContractFactory("adventure_dungeon_snowbridge");
    sd = await _sd.deploy(adv.address, attr.address, craft_m.address);

    _attacher = await ethers.getContractFactory("plunder_attacher");
    attacher = await _attacher.deploy(plunder.address, attr.address);

    await attacher.deployed().then(async () => {
      await attr.grantRole(
        ethers.utils.keccak256(
          ethers.utils.toUtf8Bytes("MANAGING_CONTRACT")
        ),
        attacher.address
      );
    });

    await sd.deployed().then(async () => {
      await craft_m.grantRole(
	ethers.utils.keccak256(
	  ethers.utils.toUtf8Bytes("MINTER_CONTRACT")
	),
	sd.address
      );
      await adv.grantRole(
	ethers.utils.keccak256(
	  ethers.utils.toUtf8Bytes("MANAGING_CONTRACT")
	),
	sd.address
      );
    });
  });

  describe("balanceOf", async function() {
    it("Should return one when one summoner is owned", async function() {
      let account = accounts[0];

      await adv.connect(account).summon(1);
      expect(await adv.balanceOf(account.address)).to.equal(1);
    });

    it("Should return two when two summoners are owned", async function() {
      let account = accounts[3];

      await adv.connect(account).summon(1);
      await adv.connect(account).summon(2);
      expect(await adv.balanceOf(account.address)).to.equal(2);
    });

    it("Should return zero when none are owned", async function() {
      let account = accounts[4];
      expect(await adv.balanceOf(account.address)).to.equal(0);
    });
  });

  describe("ownerOf", async function() {
    it("Should return the address of the owner", async function() {
      let account = accounts[0]
      await adv.connect(account).summon(1);
      expect(await adv.totalSupply()).to.equal(1);
      expect(await adv.ownerOf(0)).to.equal(account.address);
    });
  });

  describe("summon", async function() {
    it("Should summon an adventurer", async function () {
      let account = accounts[0];

      expect(await adv.totalSupply()).to.equal(0);
      await adv.connect(account).summon(1);
      expect(await adv.totalSupply()).to.equal(1);
    });
  });

  describe("tokenURI", async function() {
    it('should not error out', async function() {
      let account = accounts[0];
      await adv.connect(account).summon(8);
      let uri = await adv.tokenURI(0)
      await uriToImage('summoner', uri); // Write the svg out as a convenience
    });
  });

  describe("level_up", async function() {
    it("Should level the summoner up", async function() {

      let daysToPass = 60;
      console.log(`${daysToPass} days of adventuring, hold...`);
      let account = accounts[0];
      await adv.connect(account).summon(1);

      for (let i = 0; i < daysToPass; i++) {
        await adv.adventure(0);
        await mineBlocks(86400);
      }

      await adv.connect(account).level_up(0)

      expect((await adv.summoner(0))[3]).to.equal("2");
    });
  });

  describe("point_buy", async function() {
    it("Should increase attributes", async function () {
      let account = accounts[0];
      await adv.connect(account).summon(1);

      let daysToPass = 60;
      for (let i = 0; i < daysToPass; i++) {
        await adv.adventure(0);
        await mineBlocks(86400);
      }
      for (let i=0;i>8;i++) {
        await adv.connect(account).level_up(0)
      }

      // Expect that the summoner is minted
      expect(await adv.ownerOf(0)).to.equal(account.address);

      await attr.connect(account).point_buy(0, 8, 18, 15, 8, 15, 8);

      let scores = await attr.connect(account).ability_scores(0);
      expect(scores[0]).to.equal(8);
      expect(scores[1]).to.equal(18);


      let uri = await attr.tokenURI(0);
      await uriToImage("attrs", uri);
    });
  });

  // it("Should adventure through the snowbridge", async function () {
  //   await sd.adventure(0);
  // });

  // it("Should have a balance of 1 Craft (I)", async function () {
  //   expect(await craft_m.balanceOf(0)).to.equal(0x1);
  // });

  // it("Mint a plunder equipment card", async function () {
  //   for (let x = 0; x < test_runs; x++) {
  //     await plunder.connect(accounts[x]).mint(1, {value: ethers.utils.parseEther("1")});
  //   }
  //   expect(plunder.ownerOf(0));
  // });

  // it("Should fail claiming without a plunder", async function () {
  //   await expect(rg.connect(accounts[1]).claimByPlunder(0)).to.be.revertedWith("!owner");
  // });

  // it("Should claim RealmGold", async function () {
  //   await rg.claimByPlunder(0);
  //   console.log("Balance: ", ethers.utils.formatEther(await rg.balanceOf(accounts[0].address)));
  //   expect(ethers.utils.formatEther(await rg.balanceOf(accounts[0].address))).to.equal("10000.0");
  // });

  // it("Should fail a double claim", async function () {
  //   await expect(rg.claimByPlunder(0)).to.be.revertedWith("!claimed");
  // });

  // it("Attach a plunder card to a summoner", async function () {
  //   for (let token = 0; token < test_runs; token++) {
  //     console.log("-----------------------------------------");
  //     console.log("Running attach for token " + token)
  //     await plunder.connect(accounts[token]).approve(attacher.address, token)
  //     await attacher.connect(accounts[token]).attachPlunder(token, token);
  //     console.log(await plunder.getHead(token));
  //     console.log(await attacher.bonus(plunder.getHead(token)));
  //     console.log(await plunder.getNeck(token));
  //     console.log(await attacher.bonus(plunder.getNeck(token)));
  //     console.log(await plunder.getChest(token));
  //     console.log(await attacher.bonus(plunder.getChest(token)));
  //     console.log(await plunder.getHand(token));
  //     console.log(await attacher.bonus(plunder.getHand(token)));
  //     console.log(await plunder.getFoot(token));
  //     console.log(await attacher.bonus(plunder.getFoot(token)));
  //     console.log(await plunder.getWeapon(token));
  //     console.log(await attacher.bonus(plunder.getWeapon(token)));
  //     console.log(await attr.ability_scores(token));
  //   }
  // });
});
