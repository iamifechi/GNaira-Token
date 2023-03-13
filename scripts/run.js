const hre = require("hardhat");

async function main() {
  const GNaira = await hre.ethers.getContractFactory("GNaira");
  const gNaira = await GNaira.deploy();
  await gNaira.deployed();
  console.log("contract deployed to: ", gNaira.address);
  console.log("owner: ", await gNaira.owner());
  console.log("owners: ", await gNaira.multisigOwners(0));

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
