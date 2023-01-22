// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoRenderer.sol";
import "../PeepoToken.sol";

contract DeployPeepo is Script {
    function run() public {
        vm.startBroadcast(0x9aaC8cCDf50dD34d06DF661602076a07750941F6);
        PeepoRenderer pr = new PeepoRenderer(vm.readFileBinary("./art/peepo-7.chunk"));
        // PeepoToken pt = new PeepoToken(address(pr), bytes32(0));
        PeepoToken pt = PeepoToken(0xd7A163B8200AA77EC6c921c0df067c6f5E1D484E);
        pr.updatePeepoToken(address(pt));
        pt.updateRendererContract(address(pr));
        // pt.setMintOpen(true);
        // pt.mint(300);
        vm.stopBroadcast();
    }
}
