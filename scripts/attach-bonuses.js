const { ethers } = require("hardhat");

async function main() {
	let attacher;
	let token = 165;

	_adv = await ethers.getContractFactory("Adventure");
	adv = await _adv.deploy();

	_attr = await ethers.getContractFactory("adventure_attributes");
	attr = await _attr.deploy(adv.address);

	_plunder = await ethers.getContractFactory("Plunder");
	plunder = await _plunder.deploy();

	_attacher = await ethers.getContractFactory("plunder_attacher");
	attacher = await _attacher.deploy(plunder.address, attr.address);

	await adv.summon(8);

	await plunder.ownerClaim(token).then(async () => {
		let stat = "Dexterity";
		let total = 0;
		let parts = [
			plunder.getHead,
			plunder.getNeck,
			plunder.getChest,
			plunder.getHand,
			plunder.getFoot,
			plunder.getWeapon,
		];
		console.log(
			`If Plunder #${token} were to be attached to a summoner, stat boosts:`
		);
		console.log(
			`----------------------------------------------------------------`
		);
		for (let part of parts) {
			total += (await attacher.bonus(part.call(plunder, token))) + 1;
			if (part === plunder.getWeapon) {
				stat = "Strength";
			}
			console.log(
				`+${
					(await attacher.bonus(part.call(plunder, token))) + 1
				} ${stat}: ${await part.call(plunder, token)}`
			);
		}
		console.log(`Total: ${total}`);
	});
}

main();
