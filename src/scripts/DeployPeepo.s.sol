// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoRenderer.sol";
import "../PeepoToken.sol";

contract DeployPeepo is Script {
    address public constant FileStoreMainnet = 0x9746fD0A77829E12F8A9DBe70D7a322412325B91;
    address public constant FileStoreGoerli = 0x5E348d0975A920E9611F8140f84458998A53af94;

    function run() public {
        address fileStore;
        if (block.chainid == 1) {
            fileStore = FileStoreMainnet;
        } else if (block.chainid == 5) {
            fileStore = FileStoreGoerli;
        }

        vm.startBroadcast(0x9aaC8cCDf50dD34d06DF661602076a07750941F6);
        PeepoRenderer pr = new PeepoRenderer(fileStore, "peepo-4.chunk");
        // PeepoToken pt = new PeepoToken(address(pr), bytes32(0));
        PeepoToken pt = PeepoToken(0xd7A163B8200AA77EC6c921c0df067c6f5E1D484E);
        pr.updatePeepoToken(address(pt));
        pt.updateRendererContract(address(pr));
        // pt.setMintOpen(true);
        // pt.mint(300);
        vm.stopBroadcast();
    }
}
