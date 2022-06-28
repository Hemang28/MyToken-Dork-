const dork = artifacts.require("dork");

module.exports = function (deployer) {
  deployer.deploy(dork);
};
