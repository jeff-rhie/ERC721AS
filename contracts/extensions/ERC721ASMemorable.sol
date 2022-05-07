//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../ERC721AS.sol";
import "../interfaces/IERC721ASMemorable.sol";

/**
 * @title ERC721AS Memorable
 * @dev ERC721AS Token that can be recorded their schooling data
 */

abstract contract ERC721ASMemorable is ERC721AS, IERC721ASMemorable {
    /**
     * @dev record TokenStatus of 'tokenId'.
     *
     * Requirement:
     *
     * - The caller must own 'tokenId' or an approved operator.
     * - Does not matter whether it is on schooling or off schooling.
     *   Can save 
     */

    /*
     * mapping(schoolingId => mapping(tokenId => TokenStatus))
     */
    mapping(uint8=>mapping(uint256=>TokenStatus)) internal _schoolingRecords;

    /*
     * mapping(schoolingId => SchoolingPolicy)
     */
    mapping(uint8=>SchoolingPolicy) internal _policyRecords;

    function _recordMemory(uint256 tokenId) internal {
        TokenStatus memory _status = _tokenStatus[tokenId];
        SchoolingPolicy memory _policy = _schoolingPolicy;
        uint40 currentTime = uint40(block.timestamp);

        _status.schoolingTotal = uint40(_schoolingTotal(currentTime, _status,  _policy));
        _status.schoolingTimestamp = currentTime;
        _status.schoolingId = _policy.schoolingId;

        /**
         * @dev it Doesn't change _tokenStatus because
         * We don't want to make NFT take breaktime for recording their memory.
         */
        _schoolingRecords[_status.schoolingId][tokenId] = _status;
    }

    function _recordPolicy() internal {
        _policyRecords[_schoolingPolicy.schoolingId] = _schoolingPolicy;
    }

    function recordMemory(uint256 tokenId) external virtual override {
        address _owner = ERC721AS.ownerOf(tokenId);
        require(
            _msgSender() == _owner ||
                isApprovedForAll(_owner, _msgSender()) ||
                getApproved(tokenId) == _msgSender(),
            "ERC721ASMemorable: not approved nor owner"
        );

        _recordMemory(tokenId);
    }
}
