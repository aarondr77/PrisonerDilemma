var dilemma = artifacts.require("./PrisonerDilemma.sol");

module.exports = function(deployer) {
  deployer.deploy(dilemma);
};
