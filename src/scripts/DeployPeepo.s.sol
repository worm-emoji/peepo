// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../PeepoRenderer.sol";
import "../PeepoToken.sol";
import "../PeepoAssetStore.sol";

contract DeployPeepo is Script {
    address public immutable PeepoAssetStoreGoerli = 0xdb80EdF2abCA1942Cedfb8998F804b15C6C803D6;
    address public immutable PeepoAssetStoreMainnet = address(0);

    function saveOrUseData(string memory path) public returns (address) {
        address pasAddr = address(0);
        if (block.chainid == 0) {
            revert("Please change this line to reference deployed asset store");
        } else if (block.chainid == 5) {
            pasAddr = PeepoAssetStoreGoerli;
        } else {
            revert("Please deploy and set PeepoAssetStore for this chain");
        }
        PeepoAssetStore pas = PeepoAssetStore(pasAddr);

        bytes memory data = vm.readFileBinary(path);
        address existingPtr = pas.assetMapping(keccak256(data));
        if (existingPtr != address(0)) {
            console.log("File %s - deployed to", path, vm.toString(existingPtr));
            return existingPtr;
        }
        console.log("Deploying file %s (%s)", path, vm.toString(keccak256(data)));
        vm.startBroadcast(vm.envAddress("DEPLOYER_ADDRESS"));
        address ptr = pas.saveAsset(data);
        vm.stopBroadcast();
        return ptr;
    }

    function run() public {
        address ptr = saveOrUseData("./art/peepo.chunk");

        vm.startBroadcast(vm.envAddress("DEPLOYER_ADDRESS"));
        PeepoRenderer pr = new PeepoRenderer(ptr);
        PeepoToken pt = new PeepoToken(address(pr), bytes32(0));
        pr.updatePeepoToken(address(pt));
        pt.updateRendererContract(address(pr));
        pt.setMintOpen(true);
        pt.mint(300);
        vm.stopBroadcast();
    }
}
