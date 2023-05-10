// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./MintedCrowdsale.sol";
import "./Crowdsale.sol";

contract FreeTeeTokenSale is MintedCrowdsale {

    constructor(uint256 rate_, address payable wallet_, IERC20 token_) 
        MintedCrowdsale(rate_, wallet_, token_) {
    }

}
