// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoRenderer.sol";
import "../PeepoToken.sol";
import "./DeployPeepo.s.sol";

contract UpgradeRendererContract is Script {
    address public immutable peepoTokenDeployment = 0x9bec128790887A4cFf4372E21BF6aaC7c1a9B909;

    function run() public {
        DeployPeepo pd = new DeployPeepo();
        address ptr = pd.saveOrUseData("./art/peepo.chunk");

        vm.startBroadcast(vm.envAddress("DEPLOYER_ADDRESS"));
        PeepoRenderer pr = new PeepoRenderer(ptr);
        PeepoToken pt = PeepoToken(peepoTokenDeployment);
        pr.updatePeepoToken(peepoTokenDeployment);
        pt.updateRendererContract(address(pr));
        vm.stopBroadcast();
    }
}
