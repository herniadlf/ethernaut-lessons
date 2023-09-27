// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface BuyerSafe {
    function price() external pure returns (uint);
}

contract Shop {
    uint public price = 100;
    bool public isSold;

    function buy() public {
        BuyerSafe _buyer = BuyerSafe(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}
