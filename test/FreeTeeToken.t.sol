// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import {FreeTeeToken} from "../src/FreeTeeToken.sol";
// import {console} from "forge-std/console.sol";

contract BaseSetup is Test {
    address[] users = new address[](5);
    address public alice;
    address public bob;
    address public cat;
    address public dave;
    address public eve;

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
    }
}

contract FreeTeeTokenTest is BaseSetup {
    address public owner;
    FreeTeeToken freeTeeToken;
    uint initialSupply;

    function setUp() public override {
        BaseSetup.setUp();
        owner = address(this);
        // console.log("owner: ", owner);
        vm.label(owner, "owner");
        freeTeeToken = new FreeTeeToken();
        // console.log("FreeTeeToken: ", address(freeTeeToken));
        // console.log("alice: ", alice);
        // console.log("bob: ", bob);
        // console.log("cat: ", cat);
        // console.log("dave: ", dave);
        // console.log("eve: ", eve);
    }

    function test_OwnerHasTotalInitialSupply(uint initialSupply_) public {
        vm.assume(initialSupply_ > 0);
        initialSupply = initialSupply_;
        freeTeeToken.mint(owner, initialSupply);
        assertEq(freeTeeToken.totalSupply(), initialSupply);
        assertEq(freeTeeToken.balanceOf(owner), initialSupply);
    }

    function test_OwnerTransfersToBob(uint initialSupply_, uint amtTsf) public {
        vm.assume(initialSupply_ > 0);
        initialSupply = initialSupply_;
        test_OwnerHasTotalInitialSupply(initialSupply);
        amtTsf = bound(amtTsf, 1, initialSupply);
        freeTeeToken.transfer(bob, amtTsf);
        assertEq(freeTeeToken.balanceOf(owner), initialSupply - amtTsf);
        assertEq(freeTeeToken.balanceOf(bob), amtTsf);
    }

    function test_OwnerTransfersMoreThanBalanceToBob() public {
        uint ownerBalance = freeTeeToken.balanceOf(owner);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        freeTeeToken.transfer(bob, ownerBalance + 1);
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function test_AliceTransfersFromOwnerToBob(uint initialSupply_, uint allowAlice, uint amtAliceTsfsBobFrOwner) public {
        vm.assume(initialSupply_ > 0);
        initialSupply = initialSupply_;
        test_OwnerHasTotalInitialSupply(initialSupply);
        allowAlice = bound(allowAlice, 1, initialSupply);
        amtAliceTsfsBobFrOwner = bound(amtAliceTsfsBobFrOwner, 1, allowAlice);
        vm.expectEmit(true, true, true, true);
        emit Approval(owner, alice, allowAlice);
        emit Approval(owner, alice, allowAlice - amtAliceTsfsBobFrOwner);
        emit Transfer(owner, bob, amtAliceTsfsBobFrOwner);

        freeTeeToken.approve(alice, allowAlice);

        vm.startPrank(alice);
        freeTeeToken.transferFrom(owner, bob, amtAliceTsfsBobFrOwner);
        assertEq(freeTeeToken.balanceOf(owner), initialSupply - amtAliceTsfsBobFrOwner);
        vm.stopPrank();
    }

    function test_OwnerTransfersToBobThenBobClaims(uint initialSupply_, uint amtTsf, uint amtClaimed) public {
        vm.assume(initialSupply_ > 0 && initialSupply_ > freeTeeToken.costClaim());
        initialSupply = initialSupply_;
        amtTsf = bound(amtTsf, freeTeeToken.costClaim(), initialSupply);
        amtClaimed = bound(amtClaimed, 1, amtTsf);
        test_OwnerTransfersToBob(initialSupply, amtTsf);

        vm.prank(bob);
        freeTeeToken.claim();
        assertEq(freeTeeToken.totalSupply(), initialSupply - (freeTeeToken.costClaim()));
        assertEq(freeTeeToken.balanceOf(bob), amtTsf - (freeTeeToken.costClaim()));
    }

}
