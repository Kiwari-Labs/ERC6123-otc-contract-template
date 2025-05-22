import { expect } from "chai";
import { ethers, hardhat_reset } from "./utils.test";
import { token } from "../typechain-types/@openzeppelin/contracts";
import { parseEther } from "ethers";
// import { ERC20, constants } from "../../../constant.test";

describe("ERC6123OTC", async function () {
  const amount = parseEther("10000000");
  let tokenA: any;
  let tokenB: any;
  let tradeValidator: any;
  let otc: any;
  let accounts: any;

  // constant abi for trade validator
  const tradeDataABI = "";
  const settlementDataABI = "";
  const terminationTermsABI = "";

  // pre calculate tradeId 0
  const preCalculateTradeId = "";

  // pre encode data
  const preEncodeTradeData = "";
  const preEncodeSettleData = "";

  afterEach(async function () {
    await hardhat_reset();
  });

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    const mockTokenContract = await ethers.getContractFactory("MockERC20Token");
    const mockTradeValidator = await ethers.getContractFactory(
      "MockTradeValidator"
    );
    const mockOTCContract = await ethers.getContractFactory("MockERC6123OTC");
    // deploy mock ERC-20 token contract
    tokenA = await mockTokenContract.deploy("");
    tokenB = await mockTokenContract.deploy("");
    await tokenA.waitForDeployment();
    await tokenB.waitForDeployment();

    // deploy mock trade validator contract
    tradeValidator = await mockTradeValidator.deploy();
    await tradeValidator.waitForDeployment();

    // deploy mock ERC-6123 OTC contract
    otc = await mockOTCContract.deploy();
    await otc.waitForDeployment();

    // mint tokenA to account 1
    await tokenA.mint(accounts[1], amount);
    // account 1 approve tokenA to otc contract
    await tokenA.connect(accounts[1]).approve(otc, amount);
    // mint tokenB to account 2
    await tokenB.mint(accounts[2], amount);
    // account 2 approve tokenB to otc contract
    await tokenA.connect(accounts[2]).approve(otc, amount);
  });

  it("[SUCCESS] trade incepted", async function () {
    // encode payload

    // expect event
    await expect(
      otc
        .connect(accounts[1])
        .tradeIncepted(
          accounts[2].address,
          preEncodeTradeData,
          0,
          0,
          preEncodeSettleData
        )
    )
      .to.emit(otc, "TradeIncepted")
      .withArgs();

    // expect value
    expect(await otc.tradeCount()).to.equal(0); // no finished trade
    expect(await otc.tradeId().to.equal());
    expect(await otc.tradeState()).to.equal(1);
    expect(await otc.tradeData()).to.equal(preEncodeTradeData);
  });

  it("[SUCCESS] trade comfirmed", async function () {
    // const { } = await
    // encode payload
    // expect event
  });

  it("[SUCCESS] trade initial settlement", async function () {
    // const { } = await
    // encode payload
    // expect event
  });

  it("[SUCCESS] trade perform settlement", async function () {
    // const { } = await
    // encode payload
    // expect event
  });

  // @TODO
  it("[FAILED] trade incepted", async function () {});

  // @TODO
  it("[FAILED] trade confirmed", async function () {});

  // @TODO
  it("[FAILED] trade initial settlement", async function () {});

  it("[SUCCESS] trade perform settlement", async function () {
    // const { } = await
    // encode payload
    // expect event
  });
});
