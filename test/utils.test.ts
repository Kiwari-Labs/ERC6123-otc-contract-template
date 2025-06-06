import {AddressLike, toBeHex} from "ethers";
import {network, ethers} from "hardhat";
import {mine, time} from "@nomicfoundation/hardhat-network-helpers";
import {NumberLike} from "@nomicfoundation/hardhat-network-helpers/dist/src/types";

export const hardhat_latest = async function () {
  return await time.latest();
};

export const hardhat_latestBlock = async function () {
  return await time.latestBlock();
};

export const hardhat_mine = async function (blocks: NumberLike, options: {interval?: number} = {}) {
  await mine(blocks, options);
};

export const hardhat_increase = async function (timestamp: NumberLike) {
  await time.increase(timestamp);
};

export const hardhat_reset = async function () {
  await network.provider.send("hardhat_reset");
};

export const hardhat_impersonate = async function (address: AddressLike) {
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [address],
  });
};

export const hardhat_setBalance = async function (address: AddressLike, wei: string) {
  await network.provider.send("hardhat_setBalance", [address, toBeHex(wei, 32)]);
};

export const hardhat_stopImpersonating = async function (address: AddressLike) {
  await network.provider.request({
    method: "hardhat_stopImpersonatingAccount",
    params: [address],
  });
};
export const padIndexToData = function (index: Number) {
  // The padding is applied from the start of this string (output: 0x0001).
  return `0x${index.toString().padStart(4, "0")}`;
};

export {ethers};
