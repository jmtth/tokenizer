import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("LibertyModule", (m) => {
  const liberty = m.contract("Liberty", [1000000]);
  //m.call(liberty, "constructor", [1000000]);
  return { liberty };
});