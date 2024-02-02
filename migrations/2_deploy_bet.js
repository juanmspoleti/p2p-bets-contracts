const Bets = artifacts.require("./Bets.sol")
const { developmentChains } = require("../helper-truffle-config")

module.exports = async function (deployer, network) {
    await deployer.deploy(Bets);
}
