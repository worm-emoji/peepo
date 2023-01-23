// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoAssetStore.sol";

contract DeployPeepoAssetStore is Script {
    function run() public {
        vm.startBroadcast(0x9aaC8cCDf50dD34d06DF661602076a07750941F6);
        new PeepoAssetStore();
        vm.stopBroadcast();
    }
}
