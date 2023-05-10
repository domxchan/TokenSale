// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {FreeTeeToken} from "../src/FreeTeeToken.sol";
import {FreeTeeTokenSale} from "../src/FreeTeeTokenSale.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";

contract BaseSetup is Test {
    address [] users = new address[](5);
    address public alice;
    address public bob;
    address public cat;
    address public dave;
    address public eve;
    address payable public wallet;

    function setUp() public virtual {
        string memory mnemonic = "test test test test test test test test test test test junk";
        for (uint32 i = 0; i < 5; i++) {
            users[i] = vm.rememberKey(vm.deriveKey(mnemonic, i));
        }
        alice = users[0];
        vm.label(alice, "Alice");
        bob = users[1];
        vm.label(bob, "Bob");
        cat = users[2];
        vm.label(cat, "Cat");
        dave = users[3];
        vm.label(dave, "Dave");
        eve = users[4];
        vm.label(eve, "Eve");
        wallet = payable(vm.rememberKey(vm.deriveKey(mnemonic, 6)));
        vm.label(wallet, "Wallet");
    }
}

contract FreeTeeTokenSaleTest is BaseSetup {

    event Log(string message, uint256 value);

    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address payable public deployer;
    FreeTeeToken token;
    FreeTeeTokenSale sale;
    address payable saleAddress;

    function setUp() public override {
        BaseSetup.setUp();
        deployer = payable(address(this));
        // console.log("Token deployer: ", deployer);
        vm.label(deployer, "Deployer");
        token = new FreeTeeToken();
        // console.log(token.getRoleMemberCount(MINTER_ROLE), " MINTER_ROLE 0 ", token.getRoleMember(MINTER_ROLE,0));

        sale = new FreeTeeTokenSale(1, wallet, IERC20(token));
        saleAddress = payable(address(sale));
        // console.log("sale contract address is: ", address(sale));

        token.grantRole(MINTER_ROLE, address(sale));
        // console.log(token.getRoleMemberCount(MINTER_ROLE), " MINTER_ROLE 1 ", token.getRoleMember(MINTER_ROLE,1));
    }

    function test_DeployerHasNoTokens() public {
        assertEq(token.balanceOf(deployer), 0);
    }

    function test_TokenInitialSupplyIsEmpty() public {
        assertEq(token.totalSupply(), 0);
    }

    function test_MintedByDeployer() public {
        token.mint(deployer, 30);
        assertEq(token.balanceOf(deployer), 30);
    }

    function test_MintSellToDeployer(uint96 buyAmtDeployer, uint96 balanceDeployer) public {
        vm.assume(buyAmtDeployer <= balanceDeployer && buyAmtDeployer > 0);
        emit log_named_decimal_uint("balanceDeployer", balanceDeployer, 0);
        emit log_named_decimal_uint("buyAmtDeployer", buyAmtDeployer, 0);
        vm.deal(deployer, balanceDeployer);
        uint96 balanceBefore = uint96(deployer.balance);
        emit Log("before: ", balanceBefore);

        // Sending buyAmtDeployer from deployer to the sale contract and expect to get some FreeTeeTokens back
        // saleAddress.transfer(buyAmtDeployer);
        // bool success = saleAddress.send(buyAmtDeployer);
        (bool success, ) = saleAddress.call{value: buyAmtDeployer, gas: 500000}("");
        require(success, "Failed to send Ether to sale");

        uint96 balanceAfter = uint96(deployer.balance);
        emit Log("after: ", balanceAfter);

        assertEq(token.balanceOf(deployer), buyAmtDeployer);
        assertEq(balanceBefore - balanceAfter, buyAmtDeployer);
    }

    function test_aliceBobCanBuyToken(uint96 buyAmtAlice, uint96 balanceAlice, uint96 buyAmtBob, uint96 balanceBob) public {
        vm.assume(buyAmtAlice <= balanceAlice && buyAmtAlice > 0);
        vm.assume(buyAmtBob <= balanceBob && buyAmtBob > 0);
        vm.startPrank(alice);
        vm.deal(alice, balanceAlice);
        uint96 balanceBeforeAlice = uint96(alice.balance);
        emit Log("before-Alice: ", balanceBeforeAlice);

        // Sending amount from deployer to the sale contract and expect to get some FreeTeeTokens back
        // saleAddress.transfer(amount);
        // bool success = saleAddress.send(amount);
        (bool success, ) = saleAddress.call{value: buyAmtAlice, gas: 500000}("");
        require(success, "Failed to send Ether to sale");

        uint96 balanceAfterAlice = uint96(alice.balance);
        emit Log("after-Alice: ", balanceAfterAlice);
        vm.stopPrank();

        vm.startPrank(bob);
        vm.deal(bob, balanceBob);
        uint96 balanceBeforeBob = uint96(bob.balance);
        emit Log("before-Bob: ", balanceBeforeBob);

        // Sending amount from deployer to the sale contract and expect to get some FreeTeeTokens back
        // saleAddress.transfer(amount);
        // bool success = saleAddress.send(amount);
        (success, ) = saleAddress.call{value: buyAmtBob, gas: 50000}("");
        require(success, "Failed to send Ether to sale");

        uint96 balanceAfterBob = uint96(bob.balance);
        emit Log("after-Bob: ", balanceAfterBob);
        vm.stopPrank();

        assertEq(balanceAfterAlice, balanceBeforeAlice - buyAmtAlice);
        assertEq(balanceAfterBob, balanceBeforeBob - buyAmtBob);
        assertEq(token.totalSupply() - buyAmtBob, buyAmtAlice);
        assertEq(token.balanceOf(alice), buyAmtAlice);
        assertEq(token.balanceOf(bob), buyAmtBob);
    }

    function test_AliceTransfersToBob(uint96 buyAmtAlice, uint96 balanceAlice, uint96 buyAmtBob, uint96 balanceBob, uint96 tsfAmt) public {
        vm.assume(buyAmtAlice <= balanceAlice && buyAmtAlice > 0);
        vm.assume(buyAmtBob <= balanceBob && buyAmtBob > 0);
        vm.assume(tsfAmt <= buyAmtAlice && tsfAmt > 0);
        test_aliceBobCanBuyToken(buyAmtAlice, balanceAlice, buyAmtBob, balanceBob);
        vm.prank(alice);
        token.transfer(bob, tsfAmt);
        assertEq(token.balanceOf(alice), buyAmtAlice - tsfAmt);
        assertEq(token.balanceOf(bob) - tsfAmt, buyAmtBob);
    }

}