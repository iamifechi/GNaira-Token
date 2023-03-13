require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: __dirname + "/.env" });

const key = process.env.PRIVATE_KEY;
const url = `https://autumn-solemn-owl.ethereum-goerli.discover.quiknode.pro/2d620a732cd8916c4bc76468a5dddffad2deadd9/`

if (!key) {
  throw new Error("Please set your PRIVATE_KEY in a .env file");
}

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    goerli: {
      url,
      accounts: [`0x${key}`],
    },
  },
};
