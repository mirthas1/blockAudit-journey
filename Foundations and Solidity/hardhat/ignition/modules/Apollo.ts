import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("Apollo", (m) => {
    const apollo = m.contract("rocket");

    m.call(apollo, "setname", ["Saturn G"]);

    m.call(apollo, "launch", []);

    return { apollo };
})