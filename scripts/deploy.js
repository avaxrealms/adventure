const hre = require("hardhat");

async function main() {
    const Adventure = await hre.ethers.getContractFactory("Adventure");
    const adventure = await Adventure.deploy();

    await adventure.deployed();
    console.log("Avaxrealms Adventure deployed to:", adventure.address);

    const RGold = await hre.ethers.getContractFactory("RealmGold");
    const rGold = await RGold.deploy(adventure.address);

    console.log("RealmGold deployed to:", rGold.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
