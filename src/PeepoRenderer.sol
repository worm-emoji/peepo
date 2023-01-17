// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ethfs/IFileStore.sol";

contract PeepoRenderer {
    address public peepoToken;
    address public ethFileStore;

    constructor(address _peepoToken, address _ethFileStore) {
        peepoToken = _peepoToken;
        ethFileStore = _ethFileStore;
    }

    function renderPeepo(uint256 peepoId) public view returns (string memory) {
        IFileStore(ethFileStore).getFile("peepo-part.svg").read();
    }
}
