# **ERC721AS - Auto Staking**

## TL;DR
- ERC721AS is an zero-gas staking system for NFTs that does not require holders to ‘actively prove’ their holding status.
- Zero X Gakuen contract will enable staking multiple NFTs without any gas fee created.
- We provide it as open-source to accommodate best holder-experience for the broader community.

## What is ERC721AS?

We are here to introduce ERC721AS, an Auto-Staking system for NFTs. Auto-staking is automatic staking (literally!) without requiring you to transfer your asset into another pool nor pay any gas fee during the process. With ERC721AS, you just have to hold passively. No requirements to prove your holding status whatsoever.

Traditional staking requires the holder to ‘actively’ prove his/her holding status. You had to click the staking button, transfer the token to a staking pool, receive another token as a proof, and so on… To be honest, it kills holder-experience, sets a high threshold for beginners and most importantly, IT DOESN’T HAVE TO BE THIS WAY.

The core idea of staking is to give time value. (nothing more.) Conventional staking where you, as a holder, have to prove your holding status by transferring your asset and paying gas fee is just ‘bad mechanics’.

That is why we introduce ERC721AS, a new standard based on the first principle of staking. We abstracted the process by exceptionally focusing on giving time value.



# **How to apply it to your NFT project**

## ERC721AS
- Essential codes
  - ```IERC721AS.sol```
  - ```ERC721AS.sol```
- You should do
  - ```_applyNewStakingPolicy(...)``` to start new staking season.
  - override ```_beforeTokenTransfers(...)``` to prevent record data.
  - override ```_beforeApplyNewPolicy(...)``` to hook before new policy is applied.
  - override ```_afterApplyNewPolicy(...)``` to hook after new policy is applied.
- You should not do
  - ```_setStakingXXXX(...)``` to change staking policy without any acceptable reason.
  - ```_recordStakingStatusChange(...)``` to record staking status without any acceptable reason.

## Extensions
- ERC721AS VariableURI
  - override ```tokenURI(...)``` to return ```stakingURI``` based on ```stakingCheckpoint```
  - ```mapping(index=>string) _stakingCheckpoint``` holds checkpoint
  - ```mapping(index=>string) _stakingURI``` holds URIs
  - ```_addCheckpoint(...)``` to add new checkpoint & URI
  - ```_replaceCheckpoint(...)``` to replace existing checkpoint
  - ```_removeCheckpoint(...)``` to remove existing checpoint
  - ```uriAtIndex``` to get uri at index(0, ..., numOfCheckpoint-1)
  - ```checkpointAtIndex``` to get uri at index(0, ..., numOfCheckpoint-1)
- ERC721AS Burnarable
  - ```burn()``` to burn NFT by NFT's owner
          
- ERC721AS Memorable
  - ```mapping(uint8=>mapping(uint256=>TokenStatus)) _stakingRecords``` holds staking data
  - ```mapping(uint8=>StakingPolicy) _policyRecords``` holds staking policy
  - ```_recordPolicy(...)``` to record staking policy before new staking season, by deployer
  - ```recordMemory(...)``` to record staking data before new staking season, by NFT's owner


# **License**

[MIT LICENSE](./LICENSE.txt)

# **Contact**
- MoeKun (Developer) - [@MoeKun_XD](https://twitter.com/MoeKun_XD)
- JayB (Developer) - [@JH_BAAn](https://twitter.com/JH_BAAn)
- Jeff (Leader) - [@jeff_rhie](https://twitter.com/jeff_rhie)