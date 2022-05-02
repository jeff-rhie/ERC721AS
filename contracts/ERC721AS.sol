//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./IERC721AS.sol";

//
//  @@@@@%+@@@@@-@@@@%#: =%@@@#-           -#@@@%+  -@@@@#  %@@--@@#.@@%.%@@:+@@@@@.*%%- %%#
// .=*@@@:%@@*==+@@+:@@#*@@#-@@@-@@#-+#@@#:@@@.@@@: %@@@@# .@@%-@@# +@@.:@@@ %@*==+ @@@#-@@+
//  .@@@-.%@#=- %@#*=#@=@@@-+@@* *@@--@@* *@@* === =@@.@@# =@@*%@#  %@@:=@@*.%@#=- -@@@@#@@:
// .@@@- +@@@@#.@@@@@@*-@@@ %@@-  =@@@@+  @@@ @@@#.@@@:@@# #@@@@@+ .@@@.=@@-+@@@@#.*@@%@@@@
//.@@@=  #@#=  =@@%:@@%*@@*:@@@  .%@--@%::@@@  %@=*@@@@@@#.@@%-%@% =@@%:%@@ #@#=   @@#+@@@+
//%@@@@@-@@@@@+%@@==@@++@@%%@@- :@@#-+#@@+@@@@@@@-@@@:*@@*=@@=.*%@.=@@@@@@--@@@@@+-@@=:@@@:
//
//
// ERC721AS is implemented based on ERC721A (Copyright (c) 2022 Chiru Labs)
// ERC721AS follow same license policy to ERC721A
//
// MIT License
//
// Copyright (c) 2022 OG Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
//
/// @title ERC721AS
/// ERC721AS for 'A'uto 'S'chooling & Zero x 'G'akuen NFT smart contract
/// @author MoeKun
/// @author JayB
contract ERC721AS is Context, ERC165, IERC721AS {
    using Address for address;
    using Strings for uint256;

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;

    // The number of tokens burned.
    uint256 internal _burnCounter;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to ownership details
    // An empty struct value does not necessarily mean the token is unowned. See _ownershipOf implementation for details.
    mapping(uint256 => TokenStatus) internal _tokenStatus;

    // Mapping from address to total balance
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    SchoolingPolicy internal _schoolingPolicy;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _currentIndex = _startTokenId();
    }

    /**
     * If want to change the Start TokenId, override this function.
     */
    function _startTokenId() internal view virtual returns (uint256) {
        return 0;
    }

    /**
     * Returns whether token is schooling or not.
     */
    function isTakingBreak(uint256 tokenId)
        external
        view
        override
        returns (bool)
    {
        if (!_exists(tokenId)) revert SchoolingQueryForNonexistentToken();
        return _isTakingBreak(tokenId);
    }

    /**
     * Returns latest change time of schooling status.
     */
    function schoolingTimestamp(uint256 tokenId)
        external
        view
        override
        returns (uint256)
    {
        if (!_exists(tokenId)) revert SchoolingQueryForNonexistentToken();
        return uint256(_tokenStatus[tokenId].schoolingTimestamp);
    }

    /**
     * Returns token's total time of shcooling.
     * Used for optimizing and readablilty.
     */
    function _schoolingTotal(
        uint256 currentTime,
        TokenStatus memory sData,
        SchoolingPolicy memory pData
    ) internal pure returns (uint256) {
        // If schooling is not begun yet, total = 0
        if (pData.schoolingBegin == 0 || currentTime < pData.schoolingBegin) {
            return 0;
        }

        if (pData.schoolingEnd < currentTime) {
            if (sData.schoolingTimestamp < pData.schoolingBegin) {
                return pData.schoolingEnd - pData.schoolingBegin;
            }
            if (sData.schoolingTimestamp + pData.breaktime > pData.schoolingEnd)
                return sData.schoolingTotal;
            return
                sData.schoolingTotal +
                pData.schoolingEnd -
                pData.breaktime -
                sData.schoolingTimestamp;
        }

        if (
            sData.schoolingTimestamp == 0 ||
            sData.schoolingTimestamp < pData.schoolingBegin
        ) {
            return currentTime - uint256(pData.schoolingBegin);
        }

        if (sData.schoolingTimestamp + pData.breaktime > currentTime) {
            return uint256(sData.schoolingTotal);
        }

        return
            uint256(sData.schoolingTotal) +
            currentTime -
            uint256(sData.schoolingTimestamp) -
            uint256(pData.breaktime);
    }

    /**
     * Returns token's total time of schooling.
     */
    function schoolingTotal(uint256 tokenId)
        external
        view
        override
        returns (uint256)
    {
        if (!_exists(tokenId)) revert SchoolingQueryForNonexistentToken();
        return
            _schoolingTotal(
                block.timestamp,
                _tokenStatus[tokenId],
                _schoolingPolicy
            );
    }

    /**
     * Returns whether token is schooling or not.
     */
    function _isTakingBreak(uint256 tokenId) internal view returns (bool) {
        unchecked {
            return
                _schoolingPolicy.schoolingBegin != 0 &&
                block.timestamp >= _schoolingPolicy.schoolingBegin &&
                _tokenStatus[tokenId].schoolingTimestamp >=
                _schoolingPolicy.schoolingBegin &&
                ((_tokenStatus[tokenId].schoolingTimestamp +
                    _schoolingPolicy.breaktime) > block.timestamp);
        }
    }

    function _getSchoolingAlpha() internal view returns (uint256) {
        unchecked {
            return uint256(_schoolingPolicy.alpha);
        }
    }

    /**
     * @dev use this for auxiliary data in schooling policy.
     */
    function _setSchoolingAlpha(uint64 _alpha) internal {
        unchecked {
            _schoolingPolicy.alpha = _alpha;
        }
    }

    function _getSchoolingBeta() internal view returns (uint256) {
        unchecked {
            return uint256(_schoolingPolicy.beta);
        }
    }

    /**
     * @dev use this for auxiliary data in schooling policy.
     */
    function _setSchoolingBeta(uint64 _beta) internal {
        unchecked {
            _schoolingPolicy.beta = _beta;
        }
    }

    function _setSchoolingBreaktime(uint32 _breaktime) internal {
        unchecked {
            _schoolingPolicy.breaktime = _breaktime;
        }
    }

    function _setSchoolingBegin(uint48 _begin) internal {
        unchecked {
            _schoolingPolicy.schoolingBegin = _begin;
        }
    }

    function _setSchoolingEnd(uint48 _end) internal {
        unchecked {
            _schoolingPolicy.schoolingEnd = _end;
        }
    }

    /**
     * Returns period of timelock.
     */
    function schoolingBreaktime() external view override returns (uint256) {
        unchecked {
            return uint256(_schoolingPolicy.breaktime);
        }
    }

    function schoolingBegin() external view override returns (uint256) {
        unchecked {
            return uint256(_schoolingPolicy.schoolingBegin);
        }
    }

    function schoolingEnd() external view override returns (uint256) {
        unchecked {
            return uint256(_schoolingPolicy.schoolingEnd);
        }
    }

    /**
     * Switching token's schooling status to off in forced way
     */
    function _recordSchoolingStatusChange(uint256 tokenId) internal {
        TokenStatus memory schoolingData = _tokenStatus[tokenId];
        uint256 currentTime = uint256(block.timestamp);
        schoolingData.schoolingTotal = uint32(
            _schoolingTotal(currentTime, schoolingData, _schoolingPolicy)
        );
        schoolingData.schoolingTimestamp = uint48(currentTime);
        _tokenStatus[tokenId] = schoolingData;
    }

    /**
     * @dev Burned tokens are calculated here, use _totalMinted() if you want to count just minted tokens.
     */
    function totalSupply() public view override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
    }

    /**
     * Returns the total amount of tokens minted in the contract.
     */
    function _totalMinted() internal view returns (uint256) {
        // Counter underflow is impossible as _currentIndex does not decrement,
        unchecked {
            return _currentIndex - _startTokenId();
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view override returns (uint256) {
        if (owner == address(0)) revert BalanceQueryForZeroAddress();
        return _balances[owner];
    }

    /**
     * Gas spent here starts off proportional to the maximum mint batch size.
     * It gradually moves to O(1) as tokens get transferred around in the collection over time.
     */
    function _ownershipOf(uint256 tokenId)
        internal
        view
        returns (TokenStatus memory)
    {
        uint256 curr = tokenId;

        unchecked {
            if (_startTokenId() <= curr && curr < _currentIndex) {
                TokenStatus memory ownership = _tokenStatus[curr];
                if (!ownership.burned) {
                    if (ownership.owner != address(0)) {
                        return ownership;
                    }
                    // Invariant:
                    // There will always be an ownership that has an address and is not burned
                    // before an ownership that does not have an address and is not burned.
                    // Hence, curr will not underflow.
                    while (true) {
                        curr--;
                        ownership = _tokenStatus[curr];
                        if (ownership.owner != address(0)) {
                            return ownership;
                        }
                    }
                }
            }
        }
        revert OwnerQueryForNonexistentToken();
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view override returns (address) {
        return _ownershipOf(tokenId).owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721AS.ownerOf(tokenId);
        if (to == owner) revert ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender())) {
            revert ApprovalCallerNotOwnerNorApproved();
        }

        _approve(to, tokenId, owner);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        override
        returns (address)
    {
        if (!_exists(tokenId)) revert ApprovalQueryForNonexistentToken();

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        if (operator == _msgSender()) revert ApproveToCaller();

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        _transfer(from, to, tokenId);
        if (
            to.isContract() &&
            !_checkContractOnERC721Received(from, to, tokenId, _data)
        ) {
            revert TransferToNonERC721ReceiverImplementer();
        }
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return
            _startTokenId() <= tokenId &&
            tokenId < _currentIndex &&
            !_tokenStatus[tokenId].burned;
    }

    /**
     * @dev Equivalent to `_safeMint(to, quantity, '')`.
     */
    function _safeMint(address to, uint256 quantity) internal {
        _safeMint(to, quantity, "");
    }

    /**
     * @dev Safely mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement
     *   {IERC721Receiver-onERC721Received}, which is called for each safe transfer.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address to,
        uint256 quantity,
        bytes memory _data
    ) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _balances[to] += quantity;

            _tokenStatus[startTokenId].owner = to;

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            if (to.isContract()) {
                do {
                    emit Transfer(address(0), to, updatedIndex);
                    if (
                        !_checkContractOnERC721Received(
                            address(0),
                            to,
                            updatedIndex++,
                            _data
                        )
                    ) {
                        revert TransferToNonERC721ReceiverImplementer();
                    }
                } while (updatedIndex != end);
                // Reentrancy protection
                if (_currentIndex != startTokenId) revert();
            } else {
                do {
                    emit Transfer(address(0), to, updatedIndex++);
                } while (updatedIndex != end);
            }
            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Mints `quantity` tokens and transfers them to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `quantity` must be greater than 0.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
        if (to == address(0)) revert MintToZeroAddress();
        if (quantity == 0) revert MintZeroQuantity();

        _beforeTokenTransfers(address(0), to, startTokenId, quantity);

        // Overflows are incredibly unrealistic.
        // balance or numberMinted overflow if current value of either + quantity > 1.8e19 (2**64) - 1
        // updatedIndex overflows if _currentIndex + quantity > 1.2e77 (2**256) - 1
        unchecked {
            _balances[to] += quantity;

            _tokenStatus[startTokenId].owner = to;

            uint256 updatedIndex = startTokenId;
            uint256 end = updatedIndex + quantity;

            do {
                emit Transfer(address(0), to, updatedIndex++);
            } while (updatedIndex < end);

            _currentIndex = updatedIndex;
        }
        _afterTokenTransfers(address(0), to, startTokenId, quantity);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) private {
        TokenStatus memory prevOwnership = _ownershipOf(tokenId);

        if (prevOwnership.owner != from) revert TransferFromIncorrectOwner();

        bool isApprovedOrOwner = (_msgSender() == from ||
            isApprovedForAll(from, _msgSender()) ||
            getApproved(tokenId) == _msgSender());

        if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _beforeTokenTransfers(from, to, tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;

            TokenStatus storage currSlot = _tokenStatus[tokenId];
            currSlot.owner = to;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenStatus storage nextSlot = _tokenStatus[nextTokenId];
            if (nextSlot.owner == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.owner = from;
                }
            }
        }

        emit Transfer(from, to, tokenId);
        _afterTokenTransfers(from, to, tokenId, 1);
    }

    /**
     * @dev Equivalent to `_burn(tokenId, false)`.
     */
    function _burn(uint256 tokenId) internal virtual {
        _burn(tokenId, false);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId, bool approvalCheck) internal virtual {
        TokenStatus memory prevOwnership = _ownershipOf(tokenId);

        address from = prevOwnership.owner;

        if (approvalCheck) {
            bool isApprovedOrOwner = (_msgSender() == from ||
                isApprovedForAll(from, _msgSender()) ||
                getApproved(tokenId) == _msgSender());

            if (!isApprovedOrOwner) revert TransferCallerNotOwnerNorApproved();
        }

        _beforeTokenTransfers(from, address(0), tokenId, 1);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId, from);

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.
        unchecked {
            _balances[from] -= 1;

            // Keep track of who burned the token, and the timestamp of burning.
            TokenStatus storage currSlot = _tokenStatus[tokenId];
            currSlot.owner = from;
            currSlot.burned = true;

            // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
            uint256 nextTokenId = tokenId + 1;
            TokenStatus storage nextSlot = _tokenStatus[nextTokenId];
            if (nextSlot.owner == address(0)) {
                // This will suffice for checking _exists(nextTokenId),
                // as a burned slot cannot contain the zero address.
                if (nextTokenId != _currentIndex) {
                    nextSlot.owner = from;
                }
            }
        }

        emit Transfer(from, address(0), tokenId);
        _afterTokenTransfers(from, address(0), tokenId, 1);

        // Overflow not possible, as _burnCounter cannot be exceed _currentIndex times.
        unchecked {
            _burnCounter++;
        }
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(
        address to,
        uint256 tokenId,
        address owner
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkContractOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        try
            IERC721Receiver(to).onERC721Received(
                _msgSender(),
                from,
                tokenId,
                _data
            )
        returns (bytes4 retval) {
            return retval == IERC721Receiver(to).onERC721Received.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert TransferToNonERC721ReceiverImplementer();
            } else {
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     *
     * *** IT RECORDS SCHOOLING DATA ***
     *
     * IF YOU DON'T WANT IT, please override this funcion
     *
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {
        if (startTokenId == _currentIndex) return;
        uint256 updatedIndex = startTokenId;
        uint256 end = updatedIndex + quantity;
        do {
            _recordSchoolingStatusChange(updatedIndex++);
        } while (updatedIndex != end);
    }

    /**
     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes
     * minting.
     * And also called after one token has been burned.
     *
     * startTokenId - the first token id to be transferred
     * quantity - the amount to be transferred
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` has been
     * transferred to `to`.
     * - When `from` is zero, `tokenId` has been minted for `to`.
     * - When `to` is zero, `tokenId` has been burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual {}
}
