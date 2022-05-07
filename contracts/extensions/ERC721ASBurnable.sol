//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../ERC721AS.sol";
import "../interfaces/IERC721ASBurnable.sol";

/**
 * @title ERC721AS Burnable Token.
 * @dev ERC721AS Token that can be irreducibly burned.
 */
abstract contract ERC721ASBurnable is ERC721AS, IERC721ASBurnable {
    /**
     * @dev Burns 'tokenId'.
     *
     * Requirement:
     *
     * - The caller must own 'tokenId' or an approved operator.
     * - Does not matter whether it is on schooling or off schooling.
     *   Can burn 'tokenId' at anytime.
     */
    function burn(uint256 tokenId) external virtual override {
        address _owner = ERC721AS.ownerOf(tokenId);
        require(
            _msgSender() == _owner ||
                isApprovedForAll(_owner, _msgSender()) ||
                getApproved(tokenId) == _msgSender(),
            "ERC721ASBurnable: not approved nor owner"
        );
        _burn(tokenId);
    }
}
