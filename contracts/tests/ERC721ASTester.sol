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

    function getStakingAlpha() public view returns (uint256) {
        return _getStakingAlpha();
    }

    function setStakingAlpha(uint256 alpha) public {
        _setStakingAlpha(uint64(alpha));
    }

    function getStakingBeta() public view returns (uint256) {
        return _getStakingBeta();
    }

    function setStakingBeta(uint256 beta) public {
        _setStakingBeta(uint64(beta));
    }

    function setStakingBegin(uint256 begin) public {
        _setStakingBegin(uint40(begin));
    }

    function setStakingEnd(uint256 end) public {
        _setStakingEnd(uint40(end));
    }

    function setStakingBreaktime(uint256 breaktime) public {
        _setStakingBreaktime(uint40(breaktime));
    }

    function applyNewStakingPolicy(uint256 _begin, uint256 _end, uint256 _breaktime) public {
        _applyNewStakingPolicy(
            uint40(_begin),
            uint40(_end),
            uint40(_breaktime)
        );
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
