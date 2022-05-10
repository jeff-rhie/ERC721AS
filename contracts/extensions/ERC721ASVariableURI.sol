//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../ERC721AS.sol";
import "../interfaces/IERC721ASVariableURI.sol";

abstract contract ERC721ASVariableURI is ERC721AS, IERC721ASVariableURI {
    using Strings for uint256;
    /*
     * @dev this contract use _stakingPolicy.alpha & beta
     * - alpha : current index
     * - beta : number of checkpoint
     */
    // Presenting whether checkpoint is deleted or not.
    // "1" represent deleted.
    uint256 internal constant CHECKPOINT_DELETEDMASK = uint256(1);

    //0b1111111111111111111111111111111111111111111111111111111111111110
    uint256 internal constant CHECKPOINT_GENERATEDMASK =
        uint256(18446744073709551614);

    // Array to hold staking checkpoint
    mapping(uint256 => uint256) internal _stakingCheckpoint;

    // Array to hold URI based on staking checkpoint
    mapping(uint256 => string) internal _stakingURI;

    /**
     * @dev Adding new staking checkpoint, stakingURI and stakingURI.
     */
    function _addCheckpoint(uint256 checkpoint, string memory stakingURI)
        internal
        virtual
    {
        StakingPolicy memory _policy = _stakingPolicy;
        _stakingCheckpoint[_policy.alpha] = (checkpoint &
            CHECKPOINT_GENERATEDMASK);
        _stakingURI[_policy.alpha] = stakingURI;

        _policy.alpha++;
        _policy.beta++;
        // Update stakingPolicy.
        _stakingPolicy = _policy;
    }

    function _removeCheckpoint(uint256 index) internal virtual {
        uint256 i = 0;
        uint256 counter = 0;
        if (_stakingPolicy.beta <= index) revert CheckpointOutOfArray();
        while (true) {
            if (_isExistingCheckpoint(_stakingCheckpoint[i])) {
                counter++;
            }
            // Checkpoint deleting sequence.
            if (counter > index) {
                _stakingCheckpoint[i] |= CHECKPOINT_DELETEDMASK;
                _stakingPolicy.beta--;
                return;
            }
            i++;
        }
    }

    /**
     * Replacing certain checkpoint and uri.
     * index using for checking existence and designting certain checkpoint.
     */
    function _replaceCheckpoint(
        uint256 checkpoint,
        string memory stakingURI,
        uint256 index
    ) internal virtual {
        uint256 i = 0;
        uint256 counter = 0;
        if (_stakingPolicy.beta <= index) revert CheckpointOutOfArray();
        // counter always syncs with index+1.
        // After satisfying second "if" condition, it will return.
        // Therefore, while condition will never loops infinitely.
        while (true) {
            if (_isExistingCheckpoint(_stakingCheckpoint[i])) {
                counter++;
            }
            // Checkpoint and uri replacing sequence.
            if (counter > index) {
                _stakingCheckpoint[i] = checkpoint;
                _stakingURI[i] = stakingURI;
                return;
            }
            i++;
        }
    }

    /**
     * Retruns whether checkpoint is existing or not.
     * Used for optimizing and readability.
     */
    function _isExistingCheckpoint(uint256 _checkpoint)
        internal
        pure
        returns (bool)
    {
        return (_checkpoint & CHECKPOINT_DELETEDMASK) == 0;
    }

    /**
     * @dev Returns tokenURI of existing token.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        // Returns baseURI depending on staking status.
        string memory baseURI = _getStakingURI(tokenId);
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Returns on staking URI of 'tokenId'.
     * @dev Depending on total staking time.
     */
    function _getStakingURI(uint256 tokenId)
        internal
        view
        virtual
        returns (string memory)
    {
        TokenStatus memory sData = _tokenStatus[tokenId];
        StakingPolicy memory _policy = _stakingPolicy;
        uint256 total = uint256(
            _stakingTotal(uint40(block.timestamp), sData, _policy)
        );
        uint256 index;
        uint256 counter = 0;
        for (uint256 i = 0; i < _policy.alpha; i++) {
            if (
                _isExistingCheckpoint(_stakingCheckpoint[i]) &&
                _stakingCheckpoint[i] <= total
            ) {
                index = i;
                counter++;
            }
        }

        //if satisfying 'no checkpoint' condition.
        if (index == 0 && counter == 0) {
            return _baseURI();
        }

        return _stakingURI[index];
    }

    /**
     * Get URI at certain index.
     * index can be identified as staking.
     */
    function uriAtIndex(uint256 index)
        external
        view
        override
        returns (string memory)
    {
        if (index >= _stakingPolicy.beta) revert CheckpointOutOfArray();
        uint256 i = 0;
        uint256 counter = 0;
        while (true) {
            if (_isExistingCheckpoint(_stakingCheckpoint[i])) {
                counter++;
            }
            if (counter > index) {
                return _stakingURI[i];
            }
            i++;
        }
    }

    /**
     * Get Checkpoint at certain index.
     * index can be identified as staking.
     */
    function checkpointAtIndex(uint256 index)
        external
        view
        override
        returns (uint256)
    {
        if (index >= _stakingPolicy.beta) revert CheckpointOutOfArray();
        uint256 i = 0;
        uint256 counter = 0;
        while (true) {
            if (_isExistingCheckpoint(_stakingCheckpoint[i])) {
                counter++;
            }
            if (counter > index) {
                return _stakingCheckpoint[i];
            }
            i++;
        }
    }

    // returns number of checkpoints not deleted
    function numOfCheckpoints() external view override returns (uint256) {
        return _stakingPolicy.beta;
    }

    /**
     * @dev Hook that is called before call applyNewStakingPolicy.
     *
     * _begin     - timestamp staking begin
     * _end       - timestamp staking end
     * _breaktime - breaktime in second
     */
    function _beforeApplyNewPolicy(
        uint40 _begin,
        uint40 _end,
        uint40 _breaktime
    ) internal virtual override {
        super._beforeApplyNewPolicy(_begin, _end, _breaktime);
        StakingPolicy memory _policy = _stakingPolicy;
        _policy.alpha = 0;
        _policy.beta = 0;

        _stakingPolicy = _policy;
    }
}
