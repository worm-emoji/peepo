// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoRenderer.sol";
import "../PeepoToken.sol";

contract UpgradeRendererContract is Script {
    address public immutable peepoTokenDeployment = 0x9bec128790887A4cFf4372E21BF6aaC7c1a9B909;

    function run() public {
        vm.startBroadcast(0x9aaC8cCDf50dD34d06DF661602076a07750941F6);
        PeepoRenderer pr = new PeepoRenderer(vm.readFileBinary("./art/peepo.chunk"));
        PeepoToken pt = PeepoToken(peepoTokenDeployment);
        pr.updatePeepoToken(peepoTokenDeployment);
        pt.updateRendererContract(address(pr));
        vm.stopBroadcast();
    }
}
