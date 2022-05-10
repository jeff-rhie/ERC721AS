//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../extensions/ERC721ASMemorable.sol";

contract ERC721ASMemorableTester is ERC721ASMemorable {
    constructor() ERC721AS("ERC721ASMemorableTESTER", "TEST") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function safeMint(address to, uint256 amount) public {
        _safeMint(to, amount, "");
    }

    //transferFrom(address from, address to, uint256 tokenId)
    //safeTransferFrom(address from, address to, uint256 tokenId)

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

    function setStakingBegin(uint256 begin) public {
        _setStakingBegin(uint40(begin));
    }

    function setStakingEnd(uint256 end) public {
        _setStakingEnd(uint40(end));
    }

    function setStakingBreaktime(uint256 breaktime) public {
        _setStakingBreaktime(uint40(breaktime));
    }


    function getRecordedTimestamp(uint8 stakingId, uint256 tokenId) public view returns(uint256) {
        return uint256(_stakingRecords[stakingId][tokenId].stakingTimestamp);
    }

    function getRecordedTotal(uint8 stakingId, uint256 tokenId) public view returns(uint256) {
        return uint256(_stakingRecords[stakingId][tokenId].stakingTotal);
    }

    function getRecordedId(uint8 stakingId, uint256 tokenId) public view returns(uint256) {
        return uint256(_stakingRecords[stakingId][tokenId].stakingId);
    }

    function getRecordedOwner(uint8 stakingId, uint256 tokenId) public view returns(address) {
        return _stakingRecords[stakingId][tokenId].owner;
    }


    function getRecordedBegin(uint8 stakingId) public view returns(uint256) {
        return uint256(_policyRecords[stakingId].stakingBegin);
    }

    function getRecordedEnd(uint8 stakingId) public view returns(uint256) {
        return uint256(_policyRecords[stakingId].stakingEnd);
    }

    function getRecordedBreaktime(uint8 stakingId) public view returns(uint256) {
        return uint256(_policyRecords[stakingId].breaktime);
    }


    function getRecordedPolicyId(uint8 stakingId) public view returns(uint256) {
        return uint256(_policyRecords[stakingId].stakingId);
    }

    function recordPolicy() external {
        _recordPolicy();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}
