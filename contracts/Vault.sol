// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./ERC4626ETH.sol";

contract Vault is ERC4626ETH {
    address public flagHolder;

    constructor() payable ERC20("Vault Challenge Token", "VCT") {
        require(msg.value == 1 ether, "Must init the contract with 1 eth");
        _deposit(msg.sender, address(this), msg.value);
        //This mints thier vault token
    }

    function captureTheFlag(address newFlagHolder) external {
        //NOTE: Drain ETH Balance
        require(address(this).balance == 0, "Balance is not 0");

        flagHolder = newFlagHolder;
    }
    //NOTE: This doesn't have a fallback or recieve()
    //Can send using self destruct
}