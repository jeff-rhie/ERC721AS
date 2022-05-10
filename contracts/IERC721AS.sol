// SPDX-License-Identifier: MIT
// Creator: MoeKun, JayB
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
interface IERC721AS is IERC721, IERC721Metadata {
    /**
     * The caller must own the token or be an approved operator.
     */
    error ApprovalCallerNotOwnerNorApproved();

    /**
     * The token does not exist.
     */
    error ApprovalQueryForNonexistentToken();

    /**
     * The token does not exist.
     */
    error URIQueryForNonexistentToken();

    /**
     * The token does not exist.
     */
    error OwnerQueryForNonexistentToken();

    /**
     * The caller cannot approve to their own address.
     */
    error ApproveToCaller();

    /**
     * The caller cannot approve to the current owner.
     */
    error ApprovalToCurrentOwner();

    /**
     * Cannot query the balance for the zero address.
     */
    error BalanceQueryForZeroAddress();

    /**
     * Cannot mint to the zero address.
     */
    error MintToZeroAddress();

    /**
     * The quantity of tokens minted must be more than zero.
     */
    error MintZeroQuantity();

    /**
     * The caller must own the token or be an approved operator.
     */
    error TransferCallerNotOwnerNorApproved();

    /**
     * The token must be owned by `from`.
     */
    error TransferFromIncorrectOwner();

    /**
     * Cannot safely transfer to a contract that does not implement the ERC721Receiver interface.
     */
    error TransferToNonERC721ReceiverImplementer();

    /**
     * Cannot transfer to the zero address.
     */
    error TransferToZeroAddress();

    /**
     * The token does not exist.
     */
    error StakingQueryForNonexistentToken();

    // Compiler will pack this into a single 256bit word.
    struct TokenStatus {
        // The address of the owner.
        address owner;
        // Keeps track of the latest time User toggled staking.
        uint40 stakingTimestamp;
        // Keeps track of the total time of staking.
        // Left 4Most bit
        uint40 stakingTotal;
        // State to support multiple seasons
        uint8  stakingId;
        // Whether the token has been burned.
        bool burned;
    }

    // Compiler will pack this into a single 256bit word.
    struct StakingPolicy {
        uint64 alpha;
        uint64 beta;
        uint40 stakingBegin;
        uint40 stakingEnd;
        uint8  stakingId;
        uint40 breaktime;
    }

    /**
     * @dev Returns total staking time.
     */
    function stakingTotal(uint256 tokenId) external view returns (uint256);

    /**
     * @dev Returns latest change time of staking status.
     */
    function stakingTimestamp(uint256 tokenId)
        external
        view
        returns (uint256);

    /**
     * @dev Returns whether token is staking or not.
     */
    function isTakingBreak(uint256 tokenId) external view returns (bool);

    /**
     * @dev Returns time when staking begin
     */
    function stakingBegin() external view returns (uint256);

    /**
     * @dev Returns time when staking end
     */
    function stakingEnd() external view returns (uint256);

    /**
     * @dev Returns identifier of staking phase
     */
    function stakingId() external view returns (uint256);

    /**
     * @dev Sets the time period which blocks users from transfering their tokens.
     * @dev Will stay on current grade until time goes by.
     */
    function stakingBreaktime() external view returns (uint256);

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() external view returns (uint256);
}
