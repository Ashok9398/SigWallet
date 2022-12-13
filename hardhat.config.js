require("@nomiclabs/hardhat-waffle");
const ALCHEMY_API_KEY = "w5CmM0tEaSR6NL8BWkXC8n0euEckp1RM";
const goerli_key = "5fd8308e24a70f0f6f6444ec84df61d28e367e220fdcd36ec524660c6673f56e";
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [goerli_key]
    }
  }
};