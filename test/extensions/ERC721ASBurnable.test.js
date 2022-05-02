const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ERC721ASBurnable", async function () {
  let ERC721ASTester, tester, owner, addrList;
  beforeEach(async function () {
    /// DEPLOY
    ERC721ASTester = await ethers.getContractFactory('ERC721ASBurnableTester');
    tester = await ERC721ASTester.deploy();
    [owner, ...addrList] = await ethers.getSigners();
  });

  context(`BurnableTest`, function () {
    it(`mint(10) then burn`, async function () {
      for (i = 0; i < 10; i++) {
        await tester.mint(i % 2 == 0 ? addrList[0].address : owner.address, 1);
      }
      for (j = 0; j < 10; j++) {
        try {
          tester.connect(addrList[0]).burn(j)
          expect(j % 2).to.equal(0);
        } catch (e) {
          expect(j % 2).to.equal(1);
        }
        expect(
          (await tester.totalSupply()).toNumber()
        ).to.equal(
          10 - Math.floor((j + 1) / 2)
        );
      }
    });
  });
});
