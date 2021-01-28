const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();

const infuraKey = process.env.INFURA_URL;
const privateKey = process.env.PRIVATE_KEY;
const privateKey1 = process.env.PRIVATE_KEY1;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    rinkyby: {
      provider: () =>
        new HDWalletProvider({
          privateKeys: [privateKey, privateKey1],
          providerOrUrl: infuraKey,
        }),
      network_id: 4,
      skipDryRun: true,
    },

    // Useful for private networks
    // private: {
    // provider: () => new HDWalletProvider(mnemonic, `https://network.io`),
    // network_id: 2111,   // This network is yours, in the cloud.
    // production: true    // Treats this network as if it was a public net. (default: false)
    // }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
    useColors: true,
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.2", // Fetch exact version from solc-bin (default: truffle's version)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: false,
          runs: 200,
        },
        evmVersion: "petersburg",
      },
    },
  },
};
