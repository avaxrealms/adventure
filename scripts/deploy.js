const hre = require("hardhat");

async function main() {
    const Adventure = await hre.ethers.getContractFactory("Adventure");
    const adventure = await Adventure.deploy();

    await adventure.deployed()
    .then(() => console.log("Avaxrealms Adventure deployed to:", adventure.address));

    const RGold = await hre.ethers.getContractFactory("RealmGold");
    const rGold = await RGold.deploy(adventure.address);

    await adventure.deployed()
    .then(() => console.log("RealmGold deployed to:", rGold.address));

    const Base = await hre.ethers.getContractFactory("codex_base");
    const base = await Base.deploy();

    const Attributes = await hre.ethers.getContractFactory("adventure_attributes");
    const attributes = await Attributes.deploy(adventure.address);

    await attributes.deployed()
    .then(() => console.log("attributes deployed to:", attributes.address));

    // --

    const Codex_skills = await hre.ethers.getContractFactory("adventure_codex_skills");
    const codex_skills = await Codex_skills.deploy();

    await codex_skills.deployed()
    .then(async () => {
        const Skills = await hre.ethers.getContractFactory("adventure_skills");
        const skills = await Skills.deploy(adventure.address, attributes.address, codex_skills.address);

        await skills.deployed()
        .then(() => console.log(`skills deployed to: ${skills.address}, codex: ${codex_skills.address}`));
    });


}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
