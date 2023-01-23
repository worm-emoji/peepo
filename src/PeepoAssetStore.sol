// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "solady/utils/SSTORE2.sol";
import "openzeppelin/access/Ownable.sol";

contract PeepoAssetStore is Ownable {
    mapping(address => bool) allowedWriters;
    mapping(bytes32 => address) public assetMapping;

    error NotAllowedWriter();

    function saveAsset(bytes calldata data) public returns (address) {
        if (allowedWriters[msg.sender] == false) revert NotAllowedWriter();
        address ptr = SSTORE2.write(data);
        assetMapping[keccak256(data)] = ptr;
        return ptr;
    }

    constructor() {
        allowedWriters[msg.sender] = true;
    }

    function addAllowedWriter(address _writer) external onlyOwner {
        allowedWriters[_writer] = true;
    }

    function removeAllowedWriter(address _writer) external onlyOwner {
        allowedWriters[_writer] = false;
    }

    function read(bytes32 contentHash) external view returns (bytes memory) {
        // SSTORE2 will error if hash doesn't exist / is the zero address
        return SSTORE2.read(assetMapping[contentHash]);
    }
}
