// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

contract SelfDestructor {
    address target;

    constructor (address _target) {
        target = _target;
    }

    function implode() payable public {
        selfdestruct(payable(target));
    }
}