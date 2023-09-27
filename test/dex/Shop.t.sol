// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Shop} from "../../src/shop/Shop.sol";
import {BuyerAttack} from "../../src/shop/BuyerAttack.sol";

contract ShopTest is Test {
    Shop public shop;
    BuyerAttack public buyerAttack;
    address player = makeAddr("player");

    function setUp() public {
        shop = new Shop();
        buyerAttack = new BuyerAttack(shop);
    }

    function test_BuyerAttack() public {
        assertFalse(shop.isSold());
        assertEq(shop.price(), 100);
        buyerAttack.attack();
        assertTrue(shop.isSold());
        assertEq(shop.price(), 50);
    }
}
