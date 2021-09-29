const hre = require("hardhat");

async function main() {
    const Adventure = await hre.ethers.getContractFactory("Adventure");
    const adventure = await Adventure.deploy();

    await adventure.deployed();

    console.log("Avaxrealms Adventure deployed to:", adventure.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
