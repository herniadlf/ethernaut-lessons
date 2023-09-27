// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DenialSafe} from "../../src/denial/DenialSafe.sol";
import {DenialSafeAttack} from "../../src/denial/DenialSafeAttack.sol";

contract DenialTest is Test {
    DenialSafe public denial;
    DenialSafeAttack public denialAttack;
    address player = makeAddr("player");
    address owner = address(0xA9E);

    function setUp() public {
        denial = new DenialSafe();
        denialAttack = new DenialSafeAttack(denial);
        vm.deal(address(denial), 100);
    }

    function test_DenialSafe() public {
        vm.startPrank(player);
        denial.setWithdrawPartner(address(denialAttack));
        denial.withdraw();
        assertEq(address(denial).balance, 99);
        assertEq(address(owner).balance, 1);
    }
}
