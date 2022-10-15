// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "forge-std/Test.sol";
import "contracts/Vault.sol";
import "contracts/Drainer.sol";
import "contracts/ERC4626ETH.sol";

contract VaultTest is Test {
    Vault vault;
    uint256 assets = 1 ether;

    function setUp() public {
        vault = new Vault{value: 1 ether}();
    }

    function testExample() public {
        assertTrue(true);
    }

    function testDeposit() public {
        assertEq(Vault(vault).flagHolder(), 0x0000000000000000000000000000000000000000);
        
        vm.startPrank(msg.sender);
        Vault(vault).deposit{value: assets}(assets, msg.sender);

        uint256 balance = Vault(vault).balanceOf(msg.sender);

        vm.stopPrank();
        assertEq(balance, assets);
    }

    function testWithdraw() public {
        assertEq(Vault(vault).flagHolder(), 0x0000000000000000000000000000000000000000);

        vm.startPrank(msg.sender);
        Vault(vault).deposit{value: assets}(assets, msg.sender);

        uint256 balance = Vault(vault).balanceOf(msg.sender);
        assertEq(balance, assets);

        Vault(vault).withdraw(assets, msg.sender, msg.sender);

        uint256 newBalance = Vault(vault).balanceOf(msg.sender);
        assertEq(newBalance, 0);
        vm.stopPrank();
    }
}