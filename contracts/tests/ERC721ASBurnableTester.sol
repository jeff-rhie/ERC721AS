//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../extensions/ERC721ASBurnable.sol";

contract ERC721ASBurnableTester is ERC721ASBurnable {
    constructor() ERC721AS("ERC721ASBurnableTESTER", "TEST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function safeMint(address to, uint256 amount) public {
        _safeMint(to, amount, "");
    }

    //transferFrom(address from, address to, uint256 tokenId)
    //safeTransferFrom(address from, address to, uint256 tokenId)

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}
