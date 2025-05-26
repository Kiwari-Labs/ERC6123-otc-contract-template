import {expect} from "chai";
import {ethers, hardhat_reset} from "./utils.test";
import {parseEther} from "ethers";
require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("ERC6123OTC", async function () {
  const amount = parseEther("10000000");
  let tokenA: any;
  let tokenB: any;
  let tradeValidator: any;
  let otc: any;
  let accounts: any;

  // constant abi for trade validator
  const tradeDataABI = `["uint256","uint256","address"]`;

  // @TODO example
  const settlementDataABI = ``;
  const terminationTermsABI = ``;

  // pre calculate tradeId count:0, chainId:31337
  const preCalculateTradeId = "0xb0465bdf9e7badfbe21a0a5fda84d732235886162edc625279eb95e2066e8804";

  // pre encode data with tradeDataABI uint256:1000, uint256:2000, address:0xcf7ed3acca5a467e9e704c703e8d87f634fb0fc9
  const preEncodeTradeData =
    "0x00000000000000000000000000000000000000000000000000000000000003e800000000000000000000000000000000000000000000000000000000000007d0000000000000000000000000cf7ed3acca5a467e9e704c703e8d87f634fb0fc9";

  const preEncodeSettleData: string = "0x0000000000000000000000000000000000000000000000000000000000000001";

  afterEach(async function () {
    await hardhat_reset();
  });

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const mockTokenContract = await ethers.getContractFactory("MockERC20Token");
    const mockTradeValidator = await ethers.getContractFactory("MockTradeValidator");
    const mockOTCContract = await ethers.getContractFactory("MockERC6123OTC");
    // deploy mock ERC-20 token contract
    tokenA = await mockTokenContract.connect(accounts[0]).deploy();
    tokenB = await mockTokenContract.connect(accounts[0]).deploy();
    await tokenA.waitForDeployment();
    await tokenB.waitForDeployment();

    // deploy mock trade validator contract
    tradeValidator = await mockTradeValidator.connect(accounts[0]).deploy(tradeDataABI, settlementDataABI, terminationTermsABI);
    await tradeValidator.waitForDeployment();

    // deploy mock ERC-6123 OTC contract
    otc = await mockOTCContract
      .connect(accounts[0])
      .deploy(accounts[1].address, accounts[2].address, await tokenA.getAddress(), await tokenB.getAddress());
    await otc.waitForDeployment();

    const otcAddress = await otc.getAddress();
    // mint tokenA to account 1
    await tokenA.mint(accounts[1], amount);
    // account 1 approve tokenA to otc contract
    await tokenA.connect(accounts[1]).approve(otcAddress, amount);
    // mint tokenB to account 2
    await tokenB.mint(accounts[2], amount);
    //  account 2 approve tokenB to otc contract
    await tokenB.connect(accounts[2]).approve(otcAddress, amount);
    // set trade validator implementation
    await otc.setTradeValidator(await tradeValidator.getAddress());
  });

  it("[SUCCESS] trade incepted", async function () {
    // expect event
    await expect(otc.connect(accounts[1]).inceptTrade(accounts[2].address, preEncodeTradeData, 0, 0, preEncodeSettleData))
      .to.emit(otc, "TradeIncepted")
      .withArgs(accounts[1].address, preCalculateTradeId, preEncodeTradeData);
    // expect value
    expect(await otc.tradeCount()).to.equal(0); // no finished trade
    expect(await otc.tradeId()).to.equal(preCalculateTradeId);
    expect(await otc.tradeState()).to.equal(1);
    expect(await otc.tradeData()).to.equal(preEncodeTradeData);
    console.log(await otc.getAddress());
  });

  it("[SUCCESS] trade comfirmed", async function () {
    await otc.connect(accounts[1]).inceptTrade(accounts[2].address, preEncodeTradeData, 0, 0, preEncodeSettleData);
    // expect event
    await expect(otc.connect(accounts[2]).confirmTrade(accounts[1].address, preEncodeTradeData, 0, 0, preEncodeSettleData))
      .to.emit(otc, "TradeConfirmed")
      .withArgs(accounts[2].address, preCalculateTradeId);
    // expect value
    expect(await otc.tradeCount()).to.equal(0); // no finished trade
    expect(await otc.tradeState()).to.equal(2);
  });

  it("[SUCCESS] trade initial settlement", async function () {
    await otc.connect(accounts[1]).inceptTrade(accounts[2].address, preEncodeTradeData, 0, 0, preEncodeSettleData);
    await otc.connect(accounts[2]).confirmTrade(accounts[1].address, preEncodeTradeData, 0, 0, preEncodeSettleData);
    // expect event
    await expect(otc.connect(accounts[1]).initiateSettlement())
      .to.emit(otc, "SettlementRequested")
      .withArgs(accounts[1].address, preEncodeTradeData, ""); // fix event args
    // expect value
    expect(await otc.tradeCount()).to.equal(0); // no finished trade
    expect(await otc.tradeState()).to.equal(3);
  });

  it("[SUCCESS] trade perform settlement", async function () {
    await otc.connect(accounts[1]).inceptTrade(accounts[2].address, preEncodeTradeData, 0, 0, preEncodeSettleData);
    await otc.connect(accounts[2]).confirmTrade(accounts[1].address, preEncodeTradeData, 0, 0, preEncodeSettleData);
    await otc.connect(accounts[1]).initiateSettlement();
    // expect event
    await expect(otc.connect(accounts[2]).performSettlement(0, preEncodeSettleData))
      // .to.emit(otc, "SettlementDetermined")
      // .withArgs(accounts[2].address, 0, preEncodeSettleData);
    // expect value
    console.log(await tokenA.allowance(accounts[1].address, await otc.getAddress()));
    console.log(await tokenB.allowance(accounts[2].address, await otc.getAddress()));
    expect(await otc.tradeCount()).to.equal(1); // 1 finished trade
    expect(await otc.tradeState()).to.equal(3);
    console.log(await tokenA.balanceOf(accounts[2].address));
    console.log(await tokenB.balanceOf(accounts[1].address));
  });

  it("[FAILED] trade incepted", async function () {
    // @TODO
    // directly set storage slot for fake trade state
    // expect event
    // await otc.connect().to.equal();
    // expect value
    // await otc.connect().to.equal();
  });

  it("[FAILED] trade confirmed", async function () {
    // @TODO
  });

  it("[FAILED] trade initial settlement", async function () {
    // @TODO
  });

  it("[SUCCESS] trade perform settlement", async function () {
    // @TODO
  });
});
