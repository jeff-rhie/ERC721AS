//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../ERC721AS.sol";
import "../interfaces/IERC721ASMemorable.sol";

/**
 * @title ERC721AS Memorable
 * @dev ERC721AS Token that can be recorded their staking data
 */

abstract contract ERC721ASMemorable is ERC721AS, IERC721ASMemorable {
    /**
     * @dev record TokenStatus of 'tokenId'.
     *
     * Requirement:
     *
     * - The caller must own 'tokenId' or an approved operator.
     * - Does not matter whether it is on staking or off staking.
     *   Can save 
     */

    /*
     * mapping(stakingId => mapping(tokenId => TokenStatus))
     */
    mapping(uint8=>mapping(uint256=>TokenStatus)) internal _stakingRecords;

    /*
     * mapping(stakingId => StakingPolicy)
     */
    mapping(uint8=>StakingPolicy) internal _policyRecords;

    function _recordMemory(uint256 tokenId) internal {
        TokenStatus memory _status = _tokenStatus[tokenId];
        StakingPolicy memory _policy = _stakingPolicy;
        uint40 currentTime = uint40(block.timestamp);

        _status.stakingTotal = uint40(_stakingTotal(currentTime, _status,  _policy));
        _status.stakingTimestamp = currentTime;
        _status.stakingId = _policy.stakingId;

        /**
         * @dev it Doesn't change _tokenStatus because
         * We don't want to make NFT take breaktime for recording their memory.
         */
        _stakingRecords[_status.stakingId][tokenId] = _status;
    }

    function _recordPolicy() internal {
        _policyRecords[_stakingPolicy.stakingId] = _stakingPolicy;
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
