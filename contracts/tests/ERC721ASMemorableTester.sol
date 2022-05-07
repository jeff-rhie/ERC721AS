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

    function applyNewSchoolingPolicy(
        uint256 _begin,
        uint256 _end,
        uint256 _breaktime
    ) public {
        _applyNewSchoolingPolicy(
            uint40(_begin),
            uint40(_end),
            uint40(_breaktime)
        );
    }

    function setSchoolingBegin(uint256 begin) public {
        _setSchoolingBegin(uint40(begin));
    }

    function setSchoolingEnd(uint256 end) public {
        _setSchoolingEnd(uint40(end));
    }

    function setSchoolingBreaktime(uint256 breaktime) public {
        _setSchoolingBreaktime(uint40(breaktime));
    }


    function getRecordedTimestamp(uint8 schoolingId, uint256 tokenId) public view returns(uint256) {
        return uint256(_schoolingRecords[schoolingId][tokenId].schoolingTimestamp);
    }

    function getRecordedTotal(uint8 schoolingId, uint256 tokenId) public view returns(uint256) {
        return uint256(_schoolingRecords[schoolingId][tokenId].schoolingTotal);
    }

    function getRecordedId(uint8 schoolingId, uint256 tokenId) public view returns(uint256) {
        return uint256(_schoolingRecords[schoolingId][tokenId].schoolingId);
    }

    function getRecordedOwner(uint8 schoolingId, uint256 tokenId) public view returns(address) {
        return _schoolingRecords[schoolingId][tokenId].owner;
    }


    function getRecordedBegin(uint8 schoolingId) public view returns(uint256) {
        return uint256(_policyRecords[schoolingId].schoolingBegin);
    }

    function getRecordedEnd(uint8 schoolingId) public view returns(uint256) {
        return uint256(_policyRecords[schoolingId].schoolingEnd);
    }

    function getRecordedBreaktime(uint8 schoolingId) public view returns(uint256) {
        return uint256(_policyRecords[schoolingId].breaktime);
    }


    function getRecordedPolicyId(uint8 schoolingId) public view returns(uint256) {
        return uint256(_policyRecords[schoolingId].schoolingId);
    }

    function recordPolicy() external {
        _recordPolicy();
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
}
