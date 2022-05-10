const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ERC721ASMemorable", async function () {
  let ERC721ASTester, tester, owner, user, addrList;
  beforeEach(async function () {
    /// DEPLOY
    ERC721ASTester = await ethers.getContractFactory('ERC721ASMemorableTester');
    tester = await ERC721ASTester.deploy();
    [owner, user, ...addrList] = await ethers.getSigners();
  });

  context(`Staking Record`, function () {
    it(`addCheckpoint * 5 -> remove(2) -> replace(1),(3) -> test`, async function () {
      const simTime = Math.floor(Date.now() / 1000) + 300000;

      await network.provider.send("evm_setNextBlockTimestamp", [simTime]);
      await network.provider.send("evm_mine");

      //mint 20 nfts
      await tester.mint(owner.address, 10);
      await tester.mint(user.address, 10);

      await tester.recordPolicy();
      expect(
          (await tester.getRecordedBegin(0)).toNumber()
      ).to.equal(0);

      expect(
          (await tester.getRecordedEnd(0)).toNumber()
      ).to.equal(0);

      expect(
          (await tester.getRecordedBreaktime(0)).toNumber()
      ).to.equal(0);

      expect(
          (await tester.getRecordedPolicyId(0)).toNumber()
      ).to.equal(0);

      await tester.applyNewStakingPolicy(simTime+100, simTime+300, 10);
      await tester.recordPolicy();
      expect(
          (await tester.getRecordedBegin(0)).toNumber()
      ).to.equal(simTime+100);

      expect(
          (await tester.getRecordedEnd(0)).toNumber()
      ).to.equal(simTime+300);

      expect(
          (await tester.getRecordedBreaktime(0)).toNumber()
      ).to.equal(10);

      expect(
          (await tester.getRecordedPolicyId(0)).toNumber()
      ).to.equal(0);
      /**
       * init Staking Policy
       *
       * (begin, end, break)  =  (simTime+500, simTime+9000, 1000)
       * 
       */
      await tester.setStakingBegin(simTime + 500);
      await tester.setStakingEnd(simTime + 9000);
      await tester.setStakingBreaktime(1000);
      await tester.recordPolicy();
      expect(
          (await tester.getRecordedBegin(0)).toNumber()
      ).to.equal(simTime+500);

      expect(
          (await tester.getRecordedEnd(0)).toNumber()
      ).to.equal(simTime+9000);

      expect(
          (await tester.getRecordedBreaktime(0)).toNumber()
      ).to.equal(1000);

      expect(
          (await tester.getRecordedPolicyId(0)).toNumber()
      ).to.equal(0);

      expect((await tester.stakingBegin()).toNumber()).to.equal(simTime + 500);
      expect((await tester.stakingEnd()).toNumber()).to.equal(simTime + 9000);
      expect((await tester.stakingBreaktime()).toNumber()).to.equal(1000);

      // transfer 11 from user to owner
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 100]);
      await network.provider.send("evm_mine");

      await tester.connect(user).transferFrom(user.address, owner.address, 11);

      await tester.connect(owner).recordMemory(1);
      await tester.connect(owner).recordMemory(11);
      await tester.connect(user).recordMemory(15);

      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,1)).toNumber() - (simTime + 100)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,11)).toNumber() - (simTime + 100)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,15)).toNumber() - (simTime + 100)
        ) < 5
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,1)).toNumber() - 0
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,11)).toNumber() - 0
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,15)).toNumber() - 0
        ) < 5
      ).to.equal(
        true
      );
      // transfer 15 from user to owner
      // expect breaktime
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 800]);
      await network.provider.send("evm_mine");

      await tester.connect(user).transferFrom(user.address, owner.address, 15);

      await tester.connect(owner).recordMemory(1);
      await tester.connect(owner).recordMemory(11);
      await tester.connect(owner).recordMemory(15);

      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,1)).toNumber() - (simTime + 800)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,11)).toNumber() - (simTime + 800)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,15)).toNumber() - (simTime + 800)
        ) < 5
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,1)).toNumber() - 300
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,11)).toNumber() - 300
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,15)).toNumber() - 300
        ) < 5
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);
      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 1500]);
      await network.provider.send("evm_mine");

      await tester.connect(owner).recordMemory(1);
      await tester.connect(owner).recordMemory(11);
      await tester.connect(owner).recordMemory(15);

      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,1)).toNumber() - (simTime + 1500)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,11)).toNumber() - (simTime + 1500)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,15)).toNumber() - (simTime + 1500)
        ) < 5
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,1)).toNumber() - 1000
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,11)).toNumber() - 1000
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,15)).toNumber() - 300
        ) < 5
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);
      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 1802]);
      await network.provider.send("evm_mine");

      expect(await tester.isTakingBreak(15)).to.equal(false);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 3000]);
      await network.provider.send("evm_mine");

      await tester.connect(owner).transferFrom(owner.address, user.address, 15);

      await tester.connect(owner).recordMemory(1);
      await tester.connect(owner).recordMemory(11);
      await tester.connect(user).recordMemory(15);

      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,1)).toNumber() - 2500
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,11)).toNumber() - 2500
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,15)).toNumber() - 1500
        ) < 5
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);
      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 6000]);
      await network.provider.send("evm_mine");


      await tester.connect(user).transferFrom(user.address, owner.address, 15);

      await tester.connect(owner).recordMemory(15);


      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,15)).toNumber() - (simTime+6000)
        ) < 5
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 7000]);
      await network.provider.send("evm_mine");

      await tester.connect(owner).recordMemory(1);
      await tester.connect(owner).recordMemory(11);
      await tester.connect(owner).recordMemory(15);

      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,1)).toNumber() - 6500
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,11)).toNumber() - 6500
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,15)).toNumber() - 3500
        ) < 5
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 8800]);
      await network.provider.send("evm_mine");

      await tester.connect(owner).transferFrom(owner.address, user.address, 11);


      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 9100]);
      await network.provider.send("evm_mine");

      await tester.connect(owner).recordMemory(1);
      await tester.connect(user).recordMemory(11);
      await tester.connect(owner).recordMemory(15);

      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,1)).toNumber() - (simTime + 9100)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,11)).toNumber() - (simTime + 9100)
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTimestamp(0,15)).toNumber() - (simTime + 9100)
        ) < 5
      ).to.equal(
        true
      );


      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,1)).toNumber() - 8500
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,11)).toNumber() - 8300
        ) < 5
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.getRecordedTotal(0,15)).toNumber() - 5500
        ) < 5
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(true);
      expect(await tester.isTakingBreak(15)).to.equal(false);
    });
  });
});
