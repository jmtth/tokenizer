import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Goodies42CoreModule", (m) => {
  const owner = m.getAccount(0);

  const goodies42 = m.contract("Goodies42", [], {
    from: owner,
  });

  const goodies42Shop = m.contract("Goodies42Shop", [goodies42], {
    from: owner,
  });

  m.call(goodies42, "mint", [owner, 42000000], {
    from: owner,
  });

  return { goodies42, goodies42Shop };
});