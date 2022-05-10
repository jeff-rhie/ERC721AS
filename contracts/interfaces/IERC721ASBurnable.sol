// SPDX-License-Identifier: MIT
// Creator: MoeKun, JayB
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface IERC721ASBurnable {
    /**
     * @dev Burns 'tokenId'.
     *
     * Requirement:
     *
     * - The caller must own 'tokenId' or an approved operator.
     * - Does not matter whether it is on staking or off staking.
     *   Can burn 'tokenId' at anytime.
     */
    function burn(uint256 tokenId) external virtual;
}
