import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Goodies42BonusModule", (m) => {
  const manager1 = m.getAccount(0);
  const manager2 = m.getAccount(1);

  const goodies42multisig = m.contract(
    "Goodies42Management",
    [[manager1, manager2], 2],
    {
      from: manager1,
    }
  );

  return { goodies42multisig };
});