require("@nomiclabs/hardhat-waffle");
require("solidity-coverage");
const fs = require('fs');
require('hardhat-ethernal');
require("hardhat-gas-reporter");
require("solidity-coverage");
const Game = require('./hardhat-extensions/play');

// This is a hack to import terminal-image because the author
// is a douchebag who wont provide commonJS compatibility.
let terminalImage;
(async () => {
  terminalImage = (await import("terminal-image")).default;
})();

// Loading our extension (plugin) into HRE:
if (fs.existsSync("./addresses.json")) {
  extendEnvironment((hre) => {
    let addresses = JSON.parse(fs.readFileSync("./addresses.json"));
    hre.game = new Game(addresses);
  });
}
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: false,
        runs: 200
      }
    }
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    },
  },
  mocha: {
    timeout: 20000000
  }
};

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("testmint", "Test mint one o dem and get the tokenURI")
  .addParam("contract", "contract address")
  .addParam("tokenid", "token id")
  .setAction(async (taskArgs, hre) => {

    let Contract = await hre.ethers.getContractFactory("contracts/core/adventure.sol:Adventure");
    let contract = Contract.attach(taskArgs.contract);
    let txn = await contract.summon(taskArgs.tokenid);
    console.log(txn);
    //console.log(Buffer.from(uri, 'base64').toString('ascii'));
  });

task("gettoken", "get token and show its svg")
  .addParam("contract", "contract address")
  .addParam("tokenid", "token id")
  .setAction(async (taskArgs, hre) => {

    let Contract = await hre.ethers.getContractFactory("contracts/core/adventure.sol:Adventure");
    let contract = Contract.attach(taskArgs.contract);
    let uri = await contract.tokenURI(taskArgs.tokenid);
    let decoded = decodeUri(uri);
    let parsed = JSON.parse(decoded);
    console.log(decoded);
    displayImage(parsed["image"]);
    console.log(await terminalImage.file('output.png', {width: '50%', height: '50%'}));
  });

task("adventure", "adventure!")
  .addParam("contract", "contract address")
  .addParam("tokenid", "token id")
  .setAction(async (taskArgs, hre) => {

    let Contract = await hre.ethers.getContractFactory("contracts/core/adventure.sol:Adventure");
    let contract = Contract.attach(taskArgs.contract);
    let txn = await contract.adventure(taskArgs.tokenid);

    let uri = await contract.tokenURI(taskArgs.tokenid);
    console.log(uri);
    //console.log(Buffer.from(uri, 'base64').toString('ascii'));
  });

task("levelup", "levelup!")
  .addParam("contract", "contract address")
  .addParam("tokenid", "token id")
  .setAction(async (taskArgs, hre) => {

    let Contract = await hre.ethers.getContractFactory("contracts/core/adventure.sol:Adventure");
    let contract = Contract.attach(taskArgs.contract);
    let txn = await contract.level_up(taskArgs.tokenid);

    let uri = await contract.tokenURI(taskArgs.tokenid);
    console.log(uri);
    //console.log(Buffer.from(uri, 'base64').toString('ascii'));
  });

task("claimgold", "claim gold")
  .addParam("contract", "contract address")
  .addParam("tokenid", "token id")
  .addParam("name", "name")
  .setAction(async (taskArgs, hre) => {

    let Contract = await hre.ethers.getContractFactory("contracts/RGold.sol:RealmGold");
    let contract = Contract.attach(taskArgs.contract);
    let txn = await contract.claim(taskArgs.name, taskArgs.tokenid);

    let uri = await contract.tokenURI(taskArgs.tokenid);
    console.log(uri);
    //console.log(Buffer.from(uri, 'base64').toString('ascii'));
  });

//
// Utility Functions
//
function displayImage(uri) {
  svgDataToFile(uri, "output.svg");
  svgToPng("output.svg");
}

function decodeUri(uri) {
  b64 = uri.split(',')[1];
  let buff = new Buffer(b64, 'base64');
  return buff.toString('ascii');
}

function svgDataToFile(uri, filename) {
  b64 = uri.split(',')[1];
  let buff = new Buffer(b64, 'base64');
  let ascii = buff.toString('ascii');
  fs.writeFileSync(filename, ascii);
}

function svgToPng(svgFileName) {
  sharp(svgFileName)
    .png()
    .toFile("output.png")
    .then(async function(info) {
      console.png(require('fs').readFileSync(__dirname + '/output.png'));
    })
    .catch(function(err) {
      console.log(err);
    });
}
