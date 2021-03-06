//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../extensions/ERC721ASVariableURI.sol";

contract ERC721ASVariableURITester is ERC721ASVariableURI {
    constructor() ERC721AS("ERC721ASVariableURITESTER", "TEST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function safeMint(address to, uint256 amount) public {
        _safeMint(to, amount, "");
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

    function applyNewStakingPolicy(
        uint256 _begin,
        uint256 _end,
        uint256 _breaktime
    ) public {
        _applyNewStakingPolicy(
            uint40(_begin),
            uint40(_end),
            uint40(_breaktime)
        );
    }

    function addCheckpoint(uint256 checkpoint, string memory uri) public {
        _addCheckpoint(checkpoint, uri);
    }

    function replaceCheckpoint(
        uint256 checkpoint,
        string memory uri,
        uint256 index
    ) public {
        _replaceCheckpoint(checkpoint, uri, index);
    }

    function removeCheckpoint(uint256 index) public {
        _removeCheckpoint(index);
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function _baseURI() internal view override returns (string memory) {
        return "default/";
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}
