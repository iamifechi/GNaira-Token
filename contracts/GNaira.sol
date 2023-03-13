// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GNaira is ERC20, ERC20Burnable, Ownable {

    address public governor;
    address[] public multisigOwners;
    uint256 public minSigners; //should be atleast 70% of total signers
    mapping(address => bool) public isMultisigOwner;
    mapping(address => uint256) private balances;
    mapping(address => bool ) private isBlacklisted;
    mapping(address => bool) private isHolder;
    address[] private holders;
   

    // <------------ EVENTS ------------>
    event Blacklist(address indexed account);
    event Unblacklist(address indexed account);
    event Mint(address indexed to, uint256 amount);
    event Transfer(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

  // <------------ CONSTRUCTOR ------------>
    constructor() ERC20("G-Naira", "gNGN") {
        governor = msg.sender; //Make deployer account Governor
        multisigOwners.push(governor); //Add governor to multisig owners
        isMultisigOwner[governor] = true; //Set governer true in isMultisigOwner
        minSigners = 1; //Set minimum multisig signers to 1
    }


    // <------------  STRICTLY GOVERNOR FUNCTIONS ------------>

    //@function setBlacklist: blacklist and unblacklist an account
    //@access   onlyGovernor
    function setBlacklist(address account, bool _isBlacklisted)
        external
        onlyGovernor
    {
        //check and prevent owner from getting blacklisted
        require(owner() != account, "GNaira: CANNOT BLACKLIST OWNER!");
        isBlacklisted[account] = _isBlacklisted;
        if(_isBlacklisted){
            emit Blacklist(account);
        }else{
             emit Unblacklist(account);
        }
    }

    //@function Add multisig owner
    //@access   onlyGovernor
    function addMultisigOwner(address _newOwner) public onlyGovernor {
        require(!isMultisigOwner[_newOwner], "GNaira: Address is already a multisig owner");
        multisigOwners.push(_newOwner);
        isMultisigOwner[_newOwner] = true;

        if(multisigOwners.length >= 3){
            //make minSigners atleast 70% of total signers
            minSigners = multisigOwners.length * 70 / 100;
        }else{
            minSigners++;
        }
    }


    //@function Remove multisig owner
    //@access   onlyGovernor
    function removeMultisigOwner(address _multisigOwner) public onlyGovernor {
        require(isMultisigOwner[_multisigOwner], "GNaira: Address is not a multisig owner");
        require(_multisigOwner != governor, "GNaira: Cannot remove the governor from the multisig group");
        isMultisigOwner[_multisigOwner] = false;

        for (uint256 i = 0; i < multisigOwners.length - 1; i++) {
            if (multisigOwners[i] == _multisigOwner) {
                multisigOwners[i] = multisigOwners[multisigOwners.length - 1];
                break;
            }
        }

        multisigOwners.pop();
    }

     // <------------  GOVERNOR & MULTISIG FUNCTIONS  ------------> 
    
    //@function mint tokens
    //@access   onlyMultisig
    function mint(address to, uint256 amount)
        public
        onlyMultisig
        isNotBlacklisted(to)
    {
        require(to != address(0), "ERC20: mint to the zero address");
        _mint(to, amount);
        balances[to] += amount;
        emit Mint(to, amount);
    }

    //@function burn tokens 
    //@access   onlyGovernor
    function burn(uint256 amount) public override onlyGovernor {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

  


    // <------------  PUBLICLY ACCESSIBLE FUNCTIONS ------------>

    //@function getBlacklistedAccounts: return all blacklisted accounts
    //@access   public
    function getBlacklistedAccounts() public view returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < holders.length; i++) {
            address account = holders[i];
            if (isBlacklisted[account]) {
                count++;
            }
        }
        address[] memory result = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < holders.length; i++) {
            address account = holders[i];
            if (isBlacklisted[account]) {
                result[index] = account;
                index++;
            }
        }
        return result;
    }

    //@function getBlacklistedAccounts: return all blacklisted accounts
    //@access   public
    function getHolders() public view returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < holders.length; i++) {
            address account = holders[i];
            if (isHolder[account]) {
                count++;
            }
        }
        address[] memory result = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < holders.length; i++) {
            address account = holders[i];
            if (isHolder[account]) {
                result[index] = account;
                index++;
            }
        }
        return result;
    }


    // <------------  INTERNAL OVERRIDE FUNCTIONS  ------------> 

    //@function overriding _beforeTokenTransfer: prevent token tranfer to and from blacklisted accounts and add receiving account to holder's array
    //@access   internal
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override isNotBlacklisted(from) {
        addHolder(to);
        emit Transfer(address(0), to, amount);
    }


   




    //@function addHolder: Adds holder to holders array
    //@access   onlyGovernor
    function addHolder(address _account) _isHolder(_account) private {
         isHolder[_account] = true;
         holders.push(_account);
    }

    // <------------  MODIFIERS  ------------> 

    //@modifier onlyGovernor
    modifier onlyGovernor() {
        require(msg.sender == owner(), "GNaira: caller is not the governor");
        _;
    }

     //@modifier onlyMultisig: Ensure minimum signers requirement are met
    modifier onlyMultisig() {
        uint256 count = 0;
        for (uint256 i = 0; i < multisigOwners.length; i++) {
            if (isMultisigOwner[multisigOwners[i]]) {
                count++;
            }
        }
        require(count >= minSigners, "Minimum signers requirement not met");
        _;
    }


    //@modifier isNotBlacklisted: checks if account is blacklisted
    modifier isNotBlacklisted(address _account) {
       require(!isBlacklisted[_account], "BLACKLISTED!");
       _;
    }
   
    //@modifier isHolder: Prevent adding duplicate 
    modifier _isHolder(address _account) {
         require(!isHolder[_account], "GNaira: Address is already a holder");
         _;
    }
}
