require("dotenv").config();
const HDWalletProvider = require("@truffle/hdwallet-provider");
const { INFURA_API_KEY, MNEMONIC } = process.env;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    sepolia: {
      provider: () => new HDWalletProvider({
        mnemonic: {
          phrase: MNEMONIC,
          addressIndex: 0 // Indica la dirección que deseas usar
        },
        providerOrUrl: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      }),
      network_id: "11155111",
      gas: 4465030,
    },
  },
  compilers: {
    solc: {
      version: "^0.8.2", 
      settings: {
        evmVersion: "london",
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};
