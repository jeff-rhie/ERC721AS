const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("ERC721AS", async function () {
    let ERC721ASTester, tester, owner, addrList;
    beforeEach(async function () {
        /// DEPLOY
        ERC721ASTester = await ethers.getContractFactory('ERC721ASTester');
        tester = await ERC721ASTester.deploy();
        [owner, user, ...addrList] = await ethers.getSigners();
    });

    context(`mint(n) & exists`, function () {
        for (i = 1; i <= 10; i++) {
            it(`mint(${i}) & exists(x) for 0<=x<${i + 20}`, async function () {
                await tester.mint(addrList[0].address, i);
                for (j = 0; j < i + 20; j++) {
                    expect(await tester.exists(j)).to.equal(j < i);
                }
            });
        }
    });

    context(`safeMint(n) & exists`, function () {
        for (i = 1; i <= 10; i++) {
            it(`safeMint(${i}) & exists(x) for 0<=x<${i + 20}`, async function () {
                await tester.safeMint(addrList[0].address, i);
                for (j = 0; j < i + 20; j++) {
                    expect(await tester.exists(j)).to.equal(j < i);
                }
            });
        }
    });

    context(`mint, totalMinted, totalSupply`, function () {
        it(`mint(10) -> total -> total`, async function () {
            await tester.mint(owner.address, 10);
            expect(await tester.totalMinted()).to.equal(10);
            expect(await tester.totalSupply()).to.equal(10);

            for (var i = 0; i < 10; i++) {
                expect(await tester.exists(i)).to.equal(true);
            }
            expect(await tester.totalMinted()).to.equal(10);
            expect(await tester.totalSupply()).to.equal(10);
        });
    });

    context(`set/get staking Alpha/Beta()`, function () {
        it(`setStakingAlpha(0~100) & getStakingAlpha`, async function () {
            for (i = 0; i <= 100; i++) {
                await tester.setStakingAlpha(i);
                expect(await tester.getStakingAlpha()).to.equal(i);
            }
        });
        it(`setStakingBeta(0~100) & getStakingBeta`, async function () {
            for (i = 0; i <= 100; i++) {
                await tester.setStakingBeta(i);
                expect(await tester.getStakingBeta()).to.equal(i);
            }
        });
    });

    context(`Staking`, function () {
        it(`Staking Simulation`, async function () {
            var simTime = Math.floor(Date.now() / 1000) + 7000;

            await tester.mint(owner.address, 10);
            await tester.mint(user.address, 10);
            expect((await tester.stakingTotal(1)).toNumber()).to.equal(0);
            expect((await tester.stakingTimestamp(1)).toNumber()).to.equal(0);
            expect((await tester.isTakingBreak(0))).to.equal(false);
            expect(await tester.tokenURI(0)).to.equal('default0');


            for(var k=0; k<5; k++) {
                simTime = simTime+9100+k*200;
                tester.applyNewStakingPolicy(simTime+100, simTime+300, 10);

                expect((await tester.stakingBegin()).toNumber()).to.equal(simTime + 100);
                expect((await tester.stakingEnd()).toNumber()).to.equal(simTime + 300);
                expect((await tester.stakingBreaktime()).toNumber()).to.equal(10);

                tester.setStakingBegin(simTime + 500);
                tester.setStakingEnd(simTime + 9000);
                tester.setStakingBreaktime(1000);

                expect((await tester.stakingBegin()).toNumber()).to.equal(simTime + 500);
                expect((await tester.stakingEnd()).toNumber()).to.equal(simTime + 9000);
                expect((await tester.stakingBreaktime()).toNumber()).to.equal(1000);

                // transfer 11 from user to owner
                await network.provider.send("evm_setNextBlockTimestamp", [simTime + 100]);
                await network.provider.send("evm_mine");

                await tester.connect(user).transferFrom(user.address, owner.address, 11);

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(11)).toNumber() - (simTime + 100)
                    ) < 2
                ).to.equal(
                    true
                );
                expect((await tester.stakingTimestamp(1)).toNumber()).to.equal(0);
                expect((await tester.stakingTotal(11)).toNumber()).to.equal(0);
                expect((await tester.stakingTotal(1)).toNumber()).to.equal(0);

                // transfer 15 from user to owner
                // expect breaktime
                await network.provider.send("evm_setNextBlockTimestamp", [simTime + 800]);
                await network.provider.send("evm_mine");

                await tester.connect(user).transferFrom(user.address, owner.address, 15);

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(15)).toNumber() - (simTime + 800)
                    ) < 2
                ).to.equal(
                    true
                );

                expect(
                    Math.abs(
                        (await tester.stakingTotal(15)).toNumber() - 300
                    ) < 4
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(11)).toNumber() - 300
                    ) < 4
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(1)).toNumber() - 300
                    ) < 4
                ).to.equal(
                    true
                );

                expect(await tester.isTakingBreak(1)).to.equal(false);
                expect(await tester.isTakingBreak(11)).to.equal(false);
                expect(await tester.isTakingBreak(15)).to.equal(true);

                //check time change
                await network.provider.send("evm_setNextBlockTimestamp", [simTime + 1500]);
                await network.provider.send("evm_mine");

                //check timestamp
                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(15)).toNumber() - (simTime + 800)
                    ) < 2
                ).to.equal(
                    true
                );

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(11)).toNumber() - (simTime + 100)
                    ) < 2
                ).to.equal(
                    true
                );

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(1)).toNumber() - (0)
                    ) < 2
                ).to.equal(
                    true
                );

                //check total
                expect(
                    Math.abs(
                        (await tester.stakingTotal(15)).toNumber() - 300
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(11)).toNumber() - 1000
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(1)).toNumber() - 1000
                    ) < 2
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

                //check total
                expect(
                    Math.abs(
                        (await tester.stakingTotal(15)).toNumber() - 1500
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(11)).toNumber() - 2500
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(1)).toNumber() - 2500
                    ) < 2
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

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(15)).toNumber() - (simTime + 6000)
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
                        (await tester.stakingTotal(15)).toNumber() - 3500
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(11)).toNumber() - 6500
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(1)).toNumber() - 6500
                    ) < 2
                ).to.equal(
                    true
                );

                expect(await tester.isTakingBreak(1)).to.equal(false);
                expect(await tester.isTakingBreak(11)).to.equal(false);

                //check time change
                await network.provider.send("evm_setNextBlockTimestamp", [simTime + 8800]);
                await network.provider.send("evm_mine");

                await tester.connect(owner).transferFrom(owner.address, user.address, 11);

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(11)).toNumber() - (simTime + 8800)
                    ) < 2
                ).to.equal(
                    true
                );

                //check time change
                await network.provider.send("evm_setNextBlockTimestamp", [simTime + 9100]);
                await network.provider.send("evm_mine");

                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(1)).toNumber() - (0)
                    ) < 2
                ).to.equal(
                    true
                );


                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(11)).toNumber() - (simTime + 8800)
                    ) < 2
                ).to.equal(
                    true
                );


                expect(
                    Math.abs(
                        (await tester.stakingTimestamp(15)).toNumber() - (simTime + 6000)
                    ) < 2
                ).to.equal(
                    true
                );


                expect(
                    Math.abs(
                        (await tester.stakingTotal(15)).toNumber() - 5500
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(11)).toNumber() - 8300
                    ) < 2
                ).to.equal(
                    true
                );
                expect(
                    Math.abs(
                        (await tester.stakingTotal(1)).toNumber() - 8500
                    ) < 2
                ).to.equal(
                    true
                );

                expect(await tester.isTakingBreak(1)).to.equal(false);
                expect(await tester.isTakingBreak(11)).to.equal(true);
                expect(await tester.isTakingBreak(15)).to.equal(false);

                await tester.connect(owner).transferFrom(owner.address, user.address, 15);
            }
        });
    });
});
