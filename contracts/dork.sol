// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
//import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";


contract dork is ERC20PresetMinterPauser{
    constructor() ERC20PresetMinterPauser("dork","DK"){

    }
}

