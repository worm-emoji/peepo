// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoAssetStore.sol";

contract DeployPeepoAssetStore is Script {
    function run() public {
        vm.startBroadcast(vm.envAddress("DEPLOYER_ADDRESS"));
        new PeepoAssetStore();
        vm.stopBroadcast();
    }
}
