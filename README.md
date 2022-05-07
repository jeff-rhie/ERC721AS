# **ERC721AS - Auto Schooling**

## TLDR;
- ERC721AS is an implementation of auto-staking(or in our case, auto-schooling) to the ERC721A.
- Zero X Gakuen contract will enable **gas-free** auto staking without requiring you to transfer your NFT from your wallet.
- ERC721AS is highly scalable to any project who wishes to provide zero-gas staking to its holders and encourage diamond hands.


---

## What is ERC721AS?
<div style="padding-left: 15px">
We created ERC721AS for three simple reasons:

1) NFTs **can be** more than just jsons and jpegs.
2) NFTs **can be** more closely aligned with the project's narrative.
3) ...ETH gas fee is not kawaii.

ERC721AS will give life to your Zero X Gakuen NFTs. Your NFT will not be just a constant data set, but a living being that grows within its school life.

After looking thoroughly at the soft-staking(a.k.a. nesting) concept that Moonbirds have introduced, we thought the concept itself is here to stay, but the contract had a room for improvement in terms of optimization and scalability.

That's how we designed ERC721AS; a gas-free, developer-friendly contract that enables auto-staking.

With our design, staking is done without requiring you to transfer your NFT nor pay gas fee by clicking a 'stake button', or in our case, 'schooling button'.
</div>


## Why do we need Schooling?
<div style="padding-left: 15px">
In terms of utilitarian perspective, schooling mainly performs in two ways:

1) Rewarding system for diamond hands,
2) Accumulating time value to your NFTs.

Therefore, schooling contains many implicative possibilities. Depending on the narrative of every project, schooling can be switched to anything from dungeon adventures, isekai reincarnation to anything that makes your NFT alive and grow within timeframe.

Schooling system is highly scalable to any project who wishes to reward the diamond hands and give rich narrative your NFTs.
</div>

--- 

# **How to apply it to your new NFT**

## ERC721AS
- Essential codes
  - ```IERC721AS.sol```
  - ```ERC721AS.sol```
- You should do
  - ```_applyNewSchoolingPolicy(...)``` to start new schooling season.
  - override ```_beforeTokenTransfers(...)``` to prevent record data.
  - override ```_beforeApplyNewPolicy(...)``` to hook before new policy is applied.
  - override ```_afterApplyNewPolicy(...)``` to hook after new policy is applied.
- You should not do
  - ```_setSchoolingXXXX(...)``` to change schooling policy without any acceptable reason.
  - ```_recordSchoolingStatusChange(...)``` to record schooling status without any acceptable reason.

## Extensions
- ERC721AS VariableURI
  - override ```tokenURI(...)``` to return ```schoolingURI``` based on ```schoolingCheckpoint```
  - ```mapping(index=>string) _schoolingCheckpoint``` holds checkpoint
  - ```mapping(index=>string) _schoolingURI``` holds URIs
  - ```_addCheckpoint(...)``` to add new checkpoint & URI
  - ```_replaceCheckpoint(...)``` to replace existing checkpoint
  - ```_removeCheckpoint(...)``` to remove existing checpoint
  - ```uriAtIndex``` to get uri at index(0, ..., numOfCheckpoint-1)
  - ```checkpointAtIndex``` to get uri at index(0, ..., numOfCheckpoint-1)
- ERC721AS Burnarable
  - ```burn()``` to burn NFT by NFT's owner
          
- ERC721AS Memorable
  - ```mapping(uint8=>mapping(uint256=>TokenStatus)) _schoolingRecords``` holds schooling data
  - ```mapping(uint8=>SchoolingPolicy) _policyRecords``` holds schooling policy
  - ```_recordPolicy(...)``` to record schooling policy before new schooling season, by deployer
  - ```recordMemory(...)``` to record schooling data before new schooling season, by NFT's owner

## Agenda
- Make your NFT alive
- Make your NFT grow
- Make holder of your NFT excited
- Start new season with fresh mind
- Do not hesitate to reward NFT holders

---

# **License**

[MIT LICENSE](./LICENSE.txt)

---
# **Contact**
- MoeKun (Developer) - [@MoeKun_XD](https://twitter.com/MoeKun_XD)
- JayB (Developer) - [@JH_BAAn](https://twitter.com/JH_BAAn)
- Jeff (Leader) - [@jeff_rhie](https://twitter.com/jeff_rhie)