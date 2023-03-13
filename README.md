**An ERC20 standard token - GNaira (gNGN)** 

The gNGN consists of the following specifications:
* Compliance with [ERC20](https://docs.openzeppelin.com/contracts/erc20) standard 
* Minting of new token currency 
* Burning of token currency 
* Blacklisting of addresses to prevent them from sending and receiving tokens 
* A ‘GOVERNOR’ usually the deployer address - With actions like minting, burning and blacklisting


## Overview

### Installation

```
$ npm install
```

### To run `run.js` , 
run
```
$ npx hardhat run scripts/run.js
```

### To deploy on testnet or mainnet
Get deployment url from mainnet or testnet and set up private key in a .env file and run `deploy.js`
```
$ npx hardhat run scripts/deploy.js
```

# Available GNaira Functions

```
<------------  STRICTLY GOVERNOR FUNCTIONS ------------>

@function setBlacklist: blacklist and unblacklist an account
@parameters address account, bool _isBlacklisted
@access   onlyGovernor
   
@function addMultisigOwner(address _newOwner)
@parameters address _newOwner
@access   onlyGovernor
 

@function removeMultisigOwner
@parameters address _multisigOwner
@access   onlyGovernor
 
<------------  GOVERNOR & MULTISIG FUNCTIONS  ------------> 
    
@function mint tokens
@parameters address to, uint256 amount
@access   onlyMultisig
   
@function burn tokens 
@parameters uint256 amount
@access   onlyGovernor

<------------  PUBLICLY ACCESSIBLE FUNCTIONS ------------>

@function getBlacklistedAccounts: return all blacklisted accounts
@access   public
   
@function getBlacklistedAccounts: return all blacklisted accounts
@access   public
```



# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
