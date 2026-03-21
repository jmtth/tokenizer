import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Goodies42Module", (m) => {
  const owner = m.getAccount(0);
  const goodies42 = m.contract("Goodies42", [], {
    from: owner,
  });

  m.call(goodies42, "mint", [owner, 42000], {
    from: owner,
  });

  return { goodies42 };
});
