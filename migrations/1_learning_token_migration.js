const LearningToken = artifacts.require("LearningToken");

module.exports = function (deployer) {
  deployer.deploy(LearningToken);
};
