var Migrations = artifacts.require("./sell.sol");

module.exports = function(deployer) {
  deployer.deploy(Sellable);
};
