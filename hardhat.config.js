require("@nomiclabs/hardhat-waffle");
if (process.env.REPORT_GAS) require("hardhat-gas-reporter");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  gasReporter: {
    currency: 'USD',
    gasPrice: 1,
    enabled: process.env.REPORT_GAS
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      accounts: {
        count: 200,
        gas: 2000000000000,
        gasPrice: 1,
        accountsBalance: "10000000000000000000000000"
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
  },
};
