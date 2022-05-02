//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../ERC721AS.sol";

contract ERC721ASTester is ERC721AS {
    constructor() ERC721AS("ERC721ASTESTER", "TEST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function safeMint(address to, uint256 amount) public {
        _safeMint(to, amount, "");
    }

    function getSchoolingAlpha() public view returns (uint256) {
        return _getSchoolingAlpha();
    }

    function setSchoolingAlpha(uint256 alpha) public {
        _setSchoolingAlpha(uint64(alpha));
    }

    function getSchoolingBeta() public view returns (uint256) {
        return _getSchoolingBeta();
    }

    function setSchoolingBeta(uint256 beta) public {
        _setSchoolingBeta(uint64(beta));
    }

    function setSchoolingBegin(uint256 begin) public {
        _setSchoolingBegin(uint48(begin));
    }

    function setSchoolingEnd(uint256 end) public {
        _setSchoolingEnd(uint48(end));
    }

    function setSchoolingBreaktime(uint256 breaktime) public {
        _setSchoolingBreaktime(uint32(breaktime));
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function _baseURI()
        internal
        view
        override(ERC721AS)
        returns (string memory)
    {
        return "default";
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}
