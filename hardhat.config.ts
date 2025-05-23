import {HardhatUserConfig} from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import path from "path";

import glob from "glob";
import {subtask} from "hardhat/config";
import {TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS} from "hardhat/builtin-tasks/task-names";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
};

subtask(TASK_COMPILE_SOLIDITY_GET_SOURCE_PATHS, async (_, {config}) => {
  const mainContracts = glob.sync(path.join(config.paths.root, "contracts/**/*.sol"));
  const mockContracts = glob.sync(path.join(config.paths.root, "mocks/**/*.sol"));

  return [...mainContracts, ...mockContracts].map(path.normalize);
});

export default config;
