import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("LibertyModule", (m) => {
  const owner = m.getAccount(0);
  const liberty = m.contract("Liberty", ["Liberty Token", "LIB", 18], {
    from: owner,
  });

  m.call(liberty, "mint", [owner, 1000000], {
    from: owner,
  });

  return { liberty };
});
