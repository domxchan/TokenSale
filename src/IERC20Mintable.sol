// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IERC20Mintable
 * @dev Interface of a mintable ERC20 contract
 */
interface IERC20Mintable {
    function mint(address to, uint256 amount) external;
}