import { expect } from "chai";
import { ethers, hardhat_reset } from "./utils.test";
import {
  AbiCoder,
  id,
  isHexString,
  keccak256,
  parseEther,
  toBeHex,
  toUtf8Bytes,
} from "ethers";
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
// import { ERC20, constants } from "../../../constant.test";

describe("ERC6123OTC", async function () {
  const amount = parseEther("10000000");
  let tokenA: any;
  let tokenB: any;
  let tradeValidator: any;
  let otc: any;
  let accounts: any;

  // constant abi for trade validator
  const tradeDataABI = `["uint256","uint256","address"]`;
  const settlementDataABI = "";
  const terminationTermsABI = "";

  // pre calculate tradeId 0
  const preCalculateTradeId =
    "0xba42870e397de64dc083ba907617819d6bf1290467b168fb502d3e76866e6513";

  // pre encode data
  const preEncodeTradeData =
    "0x00000000000000000000000000000000000000000000000000000000000003e800000000000000000000000000000000000000000000000000000000000007d0000000000000000000000000cf7ed3acca5a467e9e704c703e8d87f634fb0fc9";

  const preEncodeSettleData: string = "settlement";

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
    // // deploy mock ERC-20 token contract
    tokenA = await mockTokenContract.connect(accounts[0]).deploy();
    tokenB = await mockTokenContract.connect(accounts[0]).deploy();
    await tokenA.waitForDeployment();
    await tokenB.waitForDeployment();

    // // deploy mock trade validator contract
    tradeValidator = await mockTradeValidator
      .connect(accounts[0])
      .deploy(tradeDataABI, settlementDataABI, terminationTermsABI);
    await tradeValidator.waitForDeployment();

    // // deploy mock ERC-6123 OTC contract
    otc = await mockOTCContract
      .connect(accounts[0])
      .deploy(
        accounts[1].address,
        accounts[2].address,
        await tokenA.getAddress(),
        await tokenB.getAddress()
      );
    await otc.waitForDeployment();

    // // mint tokenA to account 1
    await tokenA.mint(accounts[1], amount);
    // // account 1 approve tokenA to otc contract
    // await tokenA.connect(accounts[1]).approve(otc, amount);
    // // mint tokenB to account 2
    // await tokenB.mint(accounts[2], amount);
    // // account 2 approve tokenB to otc contract
    // await tokenA.connect(accounts[2]).approve(otc, amount);
  });

  it("pre-encoder check", async function () {
    const abiCoder = AbiCoder.defaultAbiCoder();
    const OTCContractAddress = await otc.getAddress();
    console.log(
      abiCoder.encode(
        ["uint256", "uint256", "address"],
        [1000, 2000, OTCContractAddress]
      )
    );
    console.log(accounts[1].address);
    console.log(accounts[2].address);
    console.log(
      "tradeId",
      keccak256(
        abiCoder.encode(
          ["address", "address", "string", "string", "uint256", "uint256"],
          [
            accounts[1].address,
            accounts[2].address,
            preEncodeTradeData,
            preEncodeSettleData,
            0n,
            31337n,
          ]
        )
      )
    );
  });

  it("[SUCCESS] trade incepted", async function () {
    await expect(
      otc
        .connect(accounts[1])
        .inceptTrade(
          accounts[2].address,
          preEncodeTradeData,
          0,
          0,
          preEncodeSettleData
        )
    )
      .to.emit(otc, "TradeIncepted")
      .withArgs(
        accounts[1].address,
        anyValue,
        anyValue
      );
    // expect value
    expect(await otc.tradeCount()).to.equal(0); // no finished trade
    expect(await otc.tradeId()).to.equal(preCalculateTradeId);
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
