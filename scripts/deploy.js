const hre = require("hardhat");

async function main() {
  const Adventure = await hre.ethers.getContractFactory("Adventure");
  const adventure = await Adventure.deploy();

  await adventure
    .deployed()
    .then(() =>
      console.log("Avaxrealms Adventure deployed to:", adventure.address)
    );

  const RGold = await hre.ethers.getContractFactory("RealmGold");
  const rGold = await RGold.deploy(adventure.address);

  await adventure
    .deployed()
    .then(() => console.log("RealmGold deployed to:", rGold.address));

  const Base = await hre.ethers.getContractFactory("codex_base");
  const base = await Base.deploy();

  const Attributes = await hre.ethers.getContractFactory(
    "adventure_attributes"
  );
  const attributes = await Attributes.deploy(adventure.address);

  await attributes
    .deployed()
    .then(() => console.log("attributes deployed to:", attributes.address));

  // --

  const Codex_skills = await hre.ethers.getContractFactory(
    "adventure_codex_skills"
  );
  const codex_skills = await Codex_skills.deploy();

  const Codex_base_random = await hre.ethers.getContractFactory("codex_random");
  const codex_base_random = await Codex_base_random.deploy();

  await codex_base_random
    .deployed()
    .then(() =>
      console.log(`codex-base-random deployed to: ${codex_base_random.address}`)
    );

  const Adventure_crafting_materials_i = await hre.ethers.getContractFactory(
    "adventure_crafting_materials"
  );
  const adventure_crafting_materials_i =
    await Adventure_crafting_materials_i.deploy(
      adventure.address,
      attributes.address
    );

  const Codex_goods = await hre.ethers.getContractFactory(
    "adventure_codex_goods"
  );
  const codex_goods = await Codex_goods.deploy();

  const Codex_armor = await hre.ethers.getContractFactory(
    "adventure_codex_armor"
  );
  const codex_armor = await Codex_armor.deploy();

  const Codex_weapons = await hre.ethers.getContractFactory(
    "adventure_codex_weapons"
  );
  const codex_weapons = await Codex_weapons.deploy();

  await codex_skills.deployed().then(async () => {
    const Skills = await hre.ethers.getContractFactory("adventure_skills");
    const skills = await Skills.deploy(
      adventure.address,
      attributes.address,
      codex_skills.address
    );

    await skills
      .deployed()
      .then(() =>
        console.log(
          `skills deployed to: ${skills.address}, codex: ${codex_skills.address}`
        )
      )
      .then(async () => {
        await adventure_crafting_materials_i.deployed().then(async () => {
          const Adventure_crafting = await hre.ethers.getContractFactory(
            "adventure_crafting"
          );
          const adventure_crafting = await Adventure_crafting.deploy(
            adventure.address,
            attributes.address,
            adventure_crafting_materials_i.address,
            rGold.address,
            skills.address,
            codex_base_random.address,
            codex_goods.address,
            codex_armor.address,
            codex_weapons.address
          );
            console.log(`adventure_crafting deployed to: ${adventure_crafting.address}`)
        });
      });
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
