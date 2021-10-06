function decodeUri(uri) {
  b64 = uri.split(',')[1];
  let buff = new Buffer(b64, 'base64');
  return buff.toString('ascii');
}

class Adventurer {
  constructor(game, id) {
    this.game = game;
    this.id = id;
  }

  async uri() {
    let contract = await this.game.attachToContract('Adventure');
    let uri = await contract.tokenURI(this.id);
    return JSON.parse(decodeUri(uri));
  }

  async adventure() {
    let contract = await this.game.attachToContract('Adventure');
      contract.adventure(this.id);

    return await this.uri();
  }
}

class Game {
  constructor(contracts, hre) {
    this.contracts = contracts;
    this.hre = hre;

    this.summoned = [];
  }

  async attachToContract(name) {
    let Contract = await hre.ethers.getContractFactory(name);
    let contract = await Contract.attach(this.contracts[name]);
    return contract;
  }

  async totalSupply() {
    let adventure = await this.attachToContract('Adventure');
    return await adventure.totalSupply();
  }

  async summon(id) {
    let lastId = await this.totalSupply();

    let adventure = await this.attachToContract('Adventure');
    let adv = await adventure.summon(id);

    let adventurer = new Adventurer(this, lastId + 1);
    this.summoned.push(adventurer);
    return adventurer;
  }

  async tokenURI(id) {

  }
}

module.exports = Game;
