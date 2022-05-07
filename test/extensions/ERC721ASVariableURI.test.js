const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ERC721ASVariableURI", async function () {
  let ERC721ASTester, tester, owner, user, addrList;
  beforeEach(async function () {
    /// DEPLOY
    ERC721ASTester = await ethers.getContractFactory('ERC721ASVariableURITester');
    tester = await ERC721ASTester.deploy();
    [owner, user, ...addrList] = await ethers.getSigners();
  });

  context(`Schooling Checkpoint`, function () {
    it(`addCheckpoint * 5 -> remove(2) -> replace(1),(3) -> test`, async function () {
      const simTime = Math.floor(Date.now() / 1000) + 3000000;
      const toCheckpoint = (t) => { return (t % 2 == 1) ? t - 1 : t; };

      await network.provider.send("evm_setNextBlockTimestamp", [simTime]);
      await network.provider.send("evm_mine");

      //mint 20 nfts
      await tester.mint(owner.address, 10);
      await tester.mint(user.address, 10);

      /**
       * init checkpoints and then test
       *
       * checkpoints : 1000, 2500, 4000, 8000
       * URI : 0, x, 3, y
       */
      var arr = [];
      var uri = [];
      for (i = 0; i < 5; i++) {
        const checkpoint = toCheckpoint(1000 * (i + 1));
        arr.push(checkpoint);
        uri.push(`${i}/`);

        await tester.addCheckpoint(checkpoint, `${i}/`);
        expect(
          (await tester.checkpointAtIndex(i)).toNumber()
        ).to.equal(checkpoint);
        expect(await tester.tokenURI(i)).to.equal(`default/${i}`);
      }


      await tester.removeCheckpoint(2);
      await tester.replaceCheckpoint(2500, 'x', 1);
      await tester.replaceCheckpoint(7500, 'y', 3);

      expect((await tester.checkpointAtIndex(0)).toNumber()).to.equal(arr[0]);
      expect(await tester.uriAtIndex(0)).to.equal(uri[0]);

      expect((await tester.checkpointAtIndex(1)).toNumber()).to.equal(2500);
      expect(await tester.uriAtIndex(1)).to.equal('x');

      expect((await tester.checkpointAtIndex(2)).toNumber()).to.equal(arr[3]);
      expect(await tester.uriAtIndex(2)).to.equal(uri[3]);

      expect((await tester.checkpointAtIndex(3)).toNumber()).to.equal(7500);
      expect(await tester.uriAtIndex(3)).to.equal('y');

      try {
        await tester.checkpointAtIndex(4);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }
      try {
        await tester.uriAtIndex(4);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }
      try {
        await tester.tokenURI(4);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }

      tester.applyNewSchoolingPolicy(simTime+100, simTime+300, 10);

      try {
        await tester.checkpointAtIndex(0);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }
      try {
        await tester.uriAtIndex(0);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }
      try {
        await tester.tokenURI(0);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }

      arr = [];
      uri = [];
      for (i = 0; i < 5; i++) {
        const checkpoint = toCheckpoint(1000 * (i + 1));
        arr.push(checkpoint);
        uri.push(`${i}/`);
        await tester.addCheckpoint(checkpoint, `${i}/`);
        expect(
          (await tester.checkpointAtIndex(i)).toNumber()
        ).to.equal(checkpoint);
        expect(await tester.tokenURI(i)).to.equal(`default/${i}`);
      }

      await tester.removeCheckpoint(2);
      await tester.replaceCheckpoint(2500, 'x', 1);
      await tester.replaceCheckpoint(7500, 'y', 3);

      expect((await tester.checkpointAtIndex(0)).toNumber()).to.equal(arr[0]);
      expect(await tester.uriAtIndex(0)).to.equal(uri[0]);

      expect((await tester.checkpointAtIndex(1)).toNumber()).to.equal(2500);
      expect(await tester.uriAtIndex(1)).to.equal('x');

      expect((await tester.checkpointAtIndex(2)).toNumber()).to.equal(arr[3]);
      expect(await tester.uriAtIndex(2)).to.equal(uri[3]);

      expect((await tester.checkpointAtIndex(3)).toNumber()).to.equal(7500);
      expect(await tester.uriAtIndex(3)).to.equal('y');

      try {
        await tester.checkpointAtIndex(4);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }
      try {
        await tester.uriAtIndex(4);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }
      try {
        await tester.tokenURI(4);
        expect(true).to.equal(false);
      } catch (e) {
        expect(true).to.equal(true);
      }


      /**
       * init Schooling Policy
       *
       * (begin, end, break)  =  (simTime+500, simTime+9000, 1000)
       * 
       */
      tester.setSchoolingBegin(simTime + 500);
      tester.setSchoolingEnd(simTime + 9000);
      tester.setSchoolingBreaktime(1000);

      expect((await tester.schoolingBegin()).toNumber()).to.equal(simTime + 500);
      expect((await tester.schoolingEnd()).toNumber()).to.equal(simTime + 9000);
      expect((await tester.schoolingBreaktime()).toNumber()).to.equal(1000);

      // transfer 11 from user to owner
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 100]);
      await network.provider.send("evm_mine");

      await tester.connect(user).transferFrom(user.address, owner.address, 11);

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(11)).toNumber() - (simTime + 100)
        ) < 2
      ).to.equal(
        true
      );
      expect((await tester.schoolingTimestamp(1)).toNumber()).to.equal(0);
      expect((await tester.schoolingTotal(11)).toNumber()).to.equal(0);
      expect((await tester.schoolingTotal(1)).toNumber()).to.equal(0);

      // transfer 15 from user to owner
      // expect breaktime
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 800]);
      await network.provider.send("evm_mine");

      await tester.connect(user).transferFrom(user.address, owner.address, 15);

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(15)).toNumber() - (simTime + 800)
        ) < 2
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.schoolingTotal(15)).toNumber() - 300
        ) < 4
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(11)).toNumber() - 300
        ) < 4
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(1)).toNumber() - 300
        ) < 4
      ).to.equal(
        true
      );

      expect(await tester.tokenURI(1)).to.equal("default/1");
      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);
      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 1500]);
      await network.provider.send("evm_mine");

      //check timestamp
      expect(
        Math.abs(
          (await tester.schoolingTimestamp(15)).toNumber() - (simTime + 800)
        ) < 2
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(11)).toNumber() - (simTime + 100)
        ) < 2
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(1)).toNumber() - (0)
        ) < 2
      ).to.equal(
        true
      );

      //check total
      expect(
        Math.abs(
          (await tester.schoolingTotal(15)).toNumber() - 300
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(11)).toNumber() - 1000
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(1)).toNumber() - 1000
        ) < 2
      ).to.equal(
        true
      );

      expect(await tester.tokenURI(1)).to.equal(`${uri[0]}1`);
      expect(await tester.tokenURI(11)).to.equal(`${uri[0]}11`);
      expect(await tester.tokenURI(15)).to.equal("default/15");
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

      //check total
      expect(
        Math.abs(
          (await tester.schoolingTotal(15)).toNumber() - 1500
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(11)).toNumber() - 2500
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(1)).toNumber() - 2500
        ) < 2
      ).to.equal(
        true
      );

      expect(await tester.tokenURI(1)).to.equal(`x1`);
      expect(await tester.tokenURI(11)).to.equal(`x11`);
      expect(await tester.tokenURI(15)).to.equal(`${uri[0]}15`);
      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);
      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 6000]);
      await network.provider.send("evm_mine");


      await tester.connect(user).transferFrom(user.address, owner.address, 15);

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(15)).toNumber() - (simTime + 6000)
        ) < 2
      ).to.equal(
        true
      );

      expect(await tester.isTakingBreak(15)).to.equal(true);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 7000]);
      await network.provider.send("evm_mine");
      //check total
      expect(
        Math.abs(
          (await tester.schoolingTotal(15)).toNumber() - 3500
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(11)).toNumber() - 6500
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(1)).toNumber() - 6500
        ) < 2
      ).to.equal(
        true
      );

      expect(await tester.tokenURI(1)).to.equal(`${uri[3]}1`);
      expect(await tester.tokenURI(11)).to.equal(`${uri[3]}11`);
      expect(await tester.tokenURI(15)).to.equal(`x15`);
      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(false);

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 8800]);
      await network.provider.send("evm_mine");

      await tester.connect(owner).transferFrom(owner.address, user.address, 11);

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(11)).toNumber() - (simTime + 8800)
        ) < 2
      ).to.equal(
        true
      );

      //check time change
      await network.provider.send("evm_setNextBlockTimestamp", [simTime + 9100]);
      await network.provider.send("evm_mine");

      expect(
        Math.abs(
          (await tester.schoolingTimestamp(1)).toNumber() - (0)
        ) < 2
      ).to.equal(
        true
      );


      expect(
        Math.abs(
          (await tester.schoolingTimestamp(11)).toNumber() - (simTime + 8800)
        ) < 2
      ).to.equal(
        true
      );


      expect(
        Math.abs(
          (await tester.schoolingTimestamp(15)).toNumber() - (simTime + 6000)
        ) < 2
      ).to.equal(
        true
      );

      expect(
        Math.abs(
          (await tester.schoolingTotal(15)).toNumber() - 5500
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(11)).toNumber() - 8300
        ) < 2
      ).to.equal(
        true
      );
      expect(
        Math.abs(
          (await tester.schoolingTotal(1)).toNumber() - 8500
        ) < 2
      ).to.equal(
        true
      );

      expect(await tester.tokenURI(1)).to.equal(`y1`);
      expect(await tester.tokenURI(11)).to.equal(`y11`);
      expect(await tester.tokenURI(15)).to.equal(`${uri[3]}15`);
      expect(await tester.isTakingBreak(1)).to.equal(false);
      expect(await tester.isTakingBreak(11)).to.equal(true);
      expect(await tester.isTakingBreak(15)).to.equal(false);
    });
  });
});
