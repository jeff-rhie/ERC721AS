// SPDX-License-Identifier: MIT
// Creator: MoeKun, JayB
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IERC721ASVariableURI {
    /**
     * Index is out of array's range.
     */
    error CheckpointOutOfArray();

    /**
     * returns number of checkpoints not deleted
     */
    function numOfCheckpoints() external view returns (uint256);

    /**
     * Get URI at certain index.
     * index can be identified as grade.
     */
    function uriAtIndex(uint256 index) external view returns (string memory);

    /**
     * Get Checkpoint at certain index.
     * index can be identified as grade.
     */
    function checkpointAtIndex(uint256 index) external view returns (uint256);
}
