// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract FreeTeeToken is ERC20PresetMinterPauser {

    constructor() 
        ERC20PresetMinterPauser("Free Tshirt Token", "FTT") {}

    // function burn(uint256 amount) public override {
    //     require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "FreeTeeToken: must have default admin role to burn");
    //     super.burn(amount);
    // }

    // function burnFrom(address account, uint256 amount) public override {
    //     require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "FreeTeeToken: must have default admin role to burn");
    //     super.burnFrom(account, amount);
    // }
}


