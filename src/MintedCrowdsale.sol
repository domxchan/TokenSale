// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Crowdsale.sol";
// import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

/**
 * @title MintedCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to MintedCrowdsale for minting.
 */
contract MintedCrowdsale is Crowdsale {

    constructor (uint256 rate_, address payable wallet_, IERC20 token_) 
        Crowdsale(rate_, wallet_, token_) {}

    /**
     * @dev Overrides delivery by minting tokens upon purchase.
     * @param beneficiary Token purchaser
     * @param tokenAmount Number of tokens to be minted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) override internal {
        // Potentially dangerous assumption about the type of the token.
        // require(
        //     ERC20PresetMinterPauser(address(token())).mint(beneficiary, tokenAmount),
        //         "MintedCrowdsale: minting failed"
        // );

        ERC20PresetMinterPauser(address(token())).mint(beneficiary, tokenAmount);
    }
}