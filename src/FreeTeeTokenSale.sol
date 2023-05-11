// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./MintedCrowdsale.sol";

contract FreeTeeTokenSale is MintedCrowdsale {
    address private owner;

    constructor(
        uint256 rate_,
        address payable wallet_,
        address tokenAddr_
    ) MintedCrowdsale(rate_, wallet_, IERC20(tokenAddr_)) {
        owner = msg.sender;
    }
}
