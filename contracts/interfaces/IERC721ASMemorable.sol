// SPDX-License-Identifier: MIT
// Creator: MoeKun, JayB
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IERC721ASMemorable {
    /**
     * record tokenStatus,
     * - with owner at time when data recorded
     * - with timestamp when data recorded
     * - with total at time when data recorded
     * - with current schoolingId
     */
    function recordMemory(uint256 tokenId) external virtual;
}
