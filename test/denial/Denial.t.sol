// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Denial} from "../../src/denial/Denial.sol";
import {DenialAttack} from "../../src/denial/DenialAttack.sol";

contract DenialTest is Test {
    Denial public denial;
    DenialAttack public denialAttack;
    address player = makeAddr("player");
    address owner = address(0xA9E);

    function setUp() public {
        denial = new Denial();
        denialAttack = new DenialAttack(denial);
        vm.deal(address(denial), 99);
    }

    function test_Denial() public {
        vm.startPrank(player);
        denial.setWithdrawPartner(address(denialAttack));
        console2.logString("first withdraw");
        denial.withdraw();
    }
}
