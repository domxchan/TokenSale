// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/FreeTeeToken.sol";
import "../src/FreeTeeTokenSale.sol";

contract FreeTeeTokenSaleScript is Script {

    bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address payable public constant WALLET = payable(0x3fAba54796D00dB6d34900977C8E9C9Ed926452b);
    address constant TOKENADDR = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        FreeTeeToken token = FreeTeeToken(TOKENADDR);
        FreeTeeTokenSale sale = new FreeTeeTokenSale(1, WALLET, TOKENADDR);
        token.grantRole(MINTER_ROLE, address(sale));

        vm.stopBroadcast();
    }
}
