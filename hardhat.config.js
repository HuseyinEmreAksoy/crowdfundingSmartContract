require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.28",
  networks: {
    localhost: {
      url: "http://127.0.0.1:7545", // Ganache port
      accounts: [
        "0x9fb1e9e683a2a04b8ae39efdfdfada66c7f0f239a8cd45ba64244c7c70d4c84d" // Ganache account private key
      ]
    }
  }
};
