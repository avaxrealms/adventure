const fs  = require('fs');
const hre = require("hardhat");
require('hardhat-ethernal');

const deployedContracts = {};

function encodeRoleName(roleName) {
  return ethers.utils.keccak256(
    ethers.utils.toUtf8Bytes(roleName)
  );
}

async function uploadToEthernal(name, instance) {
  console.log(`Uploading ${name} to ethernal...`);
  await hre.ethernal.push({
    name: name,
    address: instance.address
  });
}

async function deployContract(name, ...constructorArgs) {
  if (constructorArgs.length === 0) {
    constructorArgs = null;
  }

  const Contract = await hre.ethers.getContractFactory(name);
  const contract = await Contract.deploy.apply(Contract, constructorArgs);

  return await contract
    .deployed()
    .then(() => {
      uploadToEthernal(name, contract);
      console.log(`${name} deployed to:`, contract.address);
      deployedContracts[name] = contract.address;
      return contract;
    }).catch((err) => {
      console.log(arguments);
    });
};

async function main() {

  const adventure = await deployContract("Adventure");
  const plunder = await deployContract("Plunder");
  const rGold     = await deployContract("RealmGold", adventure.address, plunder.address);
  await adventure.setGoldContract(rGold.address);
  console.log("Set gold contract address for adventure contract.");

  // const base = await deployContract("codex_base");

  const attributes = await deployContract("adventure_attributes", adventure.address);

  const codexSkills     = await deployContract("adventure_codex_skills");
  const codexBaseRandom = await deployContract("codex_random");

  const adventureCraftingMaterials = await deployContract(
    "adventure_crafting_materials",
    adventure.address,
    attributes.address
  );

  const codexGoods   = await deployContract("adventure_codex_goods");
  const codexArmor   = await deployContract("adventure_codex_armor");
  const codexWeapons = await deployContract("adventure_codex_weapons");

  const attacher     = await deployContract(
    "plunder_attacher",
    plunder.address,
    attributes.address
  );

  const adventureSkills = await deployContract(
    "adventure_skills",
    adventure.address,
    attributes.address,
    codexSkills.address
  );

  const snowBridgeDungeon = await deployContract(
    "adventure_dungeon_snowbridge",
    adventure.address,
    attributes.address,
    adventureCraftingMaterials.address
  );

  await adventureCraftingMaterials.grantRole(
    encodeRoleName("MINTER_CONTRACT"),
    snowBridgeDungeon.address
  );
  await adventure.grantRole(
    encodeRoleName("MANAGING_CONTRACT"),
    snowBridgeDungeon.address
  );
  await attributes.grantRole(
    encodeRoleName("MANAGING_CONTRACT"),
    attacher.address
  );

  const adventureCrafting = await deployContract(
    "adventure_crafting",
    adventure.address,
    attributes.address,
    adventureCraftingMaterials.address,
    rGold.address,
    codexSkills.address,
    codexBaseRandom.address,
    codexGoods.address,
    codexArmor.address,
    codexWeapons.address
  );
}

function writeAddressesFile() {
  fs.writeFileSync("./addresses.json", JSON.stringify(deployedContracts));
};

main()
  .then(() => {
    console.log(deployedContracts);
    writeAddressesFile();
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
