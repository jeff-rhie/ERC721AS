//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Strings.sol";
import "../ERC721AS.sol";
import "../interfaces/IERC721ASVariableURI.sol";

abstract contract ERC721ASVariableURI is ERC721AS, IERC721ASVariableURI {
    using Strings for uint256;
    /*
     * alpha : current index
     * beta : number of checkpoint
     */
    // Presenting whether checkpoint is deleted or not.
    // "1" represent deleted.
    uint256 internal constant CHECKPOINT_DELETEDMASK = uint256(1);

    //0b1111111111111111111111111111111111111111111111111111111111111110
    uint256 internal constant CHECKPOINT_GENERATEDMASK =
        uint256(18446744073709551614);

    // Array to hold schooling checkpoint
    mapping(uint256 => uint256) internal _schoolingCheckpoint;

    // Array to hold URI based on schooling checkpoint
    mapping(uint256 => string) internal _schoolingURI;

    /**
     * @dev Adding new schooling checkpoint, schoolingURI and schoolingURI.
     */
    function _addCheckpoint(uint256 checkpoint, string memory schoolingURI)
        internal
        virtual
    {
        SchoolingPolicy memory _policy = _schoolingPolicy;
        _schoolingCheckpoint[_policy.alpha] = (checkpoint &
            CHECKPOINT_GENERATEDMASK);
        _schoolingURI[_policy.alpha] = schoolingURI;

        _policy.alpha++;
        _policy.beta++;
        // Update schoolingPolicy.
        _schoolingPolicy = _policy;
    }

    function _removeCheckpoint(uint256 index) internal virtual {
        uint256 i = 0;
        uint256 counter = 0;
        if (_schoolingPolicy.beta <= index) revert CheckpointOutOfArray();
        while (true) {
            if (_isExistingCheckpoint(_schoolingCheckpoint[i])) {
                counter++;
            }
            // Checkpoint deleting sequence.
            if (counter > index) {
                _schoolingCheckpoint[i] |= CHECKPOINT_DELETEDMASK;
                _schoolingPolicy.beta--;
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
        string memory schoolingURI,
        uint256 index
    ) internal virtual {
        uint256 i = 0;
        uint256 counter = 0;
        if (_schoolingPolicy.beta <= index) revert CheckpointOutOfArray();
        // counter always syncs with index+1.
        // After satisfying second "if" condition, it will return.
        // Therefore, while condition will never loops infinitely.
        while (true) {
            if (_isExistingCheckpoint(_schoolingCheckpoint[i])) {
                counter++;
            }
            // Checkpoint and uri replacing sequence.
            if (counter > index) {
                _schoolingCheckpoint[i] = checkpoint;
                _schoolingURI[i] = schoolingURI;
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
        // Returns baseURI depending on schooling status.
        string memory baseURI = _getSchoolingURI(tokenId);
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Returns on schooling URI of 'tokenId'.
     * @dev Depending on total schooling time.
     */
    function _getSchoolingURI(uint256 tokenId)
        internal
        view
        virtual
        returns (string memory)
    {
        if (!_exists(tokenId)) revert SchoolingQueryForNonexistentToken();
        TokenStatus memory sData = _tokenStatus[tokenId];
        SchoolingPolicy memory pData = _schoolingPolicy;
        uint256 schoolingTotal = _schoolingTotal(block.timestamp, sData, pData);
        uint256 index;
        uint256 counter = 0;
        for (uint256 i = 0; i < pData.alpha; i++) {
            if (
                _isExistingCheckpoint(_schoolingCheckpoint[i]) &&
                _schoolingCheckpoint[i] <= schoolingTotal
            ) {
                index = i;
                counter++;
            }
        }

        //if satisfying 'no checkpoint' condition.
        if (index == 0 && counter == 0) {
            return _baseURI();
        }

        return _schoolingURI[index];
    }

    /**
     * Get URI at certain index.
     * index can be identified as schooling.
     */
    function uriAtIndex(uint256 index)
        external
        view
        override
        returns (string memory)
    {
        if (index >= _schoolingPolicy.beta) revert CheckpointOutOfArray();
        uint256 i = 0;
        uint256 counter = 0;
        if (_schoolingPolicy.beta <= index) revert CheckpointOutOfArray();
        while (true) {
            if (_isExistingCheckpoint(_schoolingCheckpoint[i])) {
                counter++;
            }
            if (counter > index) {
                return _schoolingURI[i];
            }
            i++;
        }
    }

    /**
     * Get Checkpoint at certain index.
     * index can be identified as schooling.
     */
    function checkpointAtIndex(uint256 index)
        external
        view
        override
        returns (uint256)
    {
        if (index >= _schoolingPolicy.beta) revert CheckpointOutOfArray();
        uint256 i = 0;
        uint256 counter = 0;
        if (_schoolingPolicy.beta <= index) revert CheckpointOutOfArray();
        while (true) {
            if (_isExistingCheckpoint(_schoolingCheckpoint[i])) {
                counter++;
            }
            if (counter > index) {
                return _schoolingCheckpoint[i];
            }
            i++;
        }
    }

    // returns number of checkpoints not deleted
    function numOfCheckpoints() external view override returns (uint256) {
        return _schoolingPolicy.beta;
    }
}
