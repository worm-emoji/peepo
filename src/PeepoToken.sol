// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ERC721A/ERC721A.sol";
import "openzeppelin/access/Ownable.sol";

contract PeepoToken is ERC721A, Ownable {
    address public rendererContract;

    constructor(address _rendererContract) ERC721A("peepo in chain", "PEEPO") {
        rendererContract = _rendererContract;
    }

    function withdraw() external onlyOwner {
        payable(this.owner()).transfer(address(this).balance);
    }

    // owner functions
    function updateRendererContract(address _rendererContract) external onlyOwner {
        rendererContract = _rendererContract;
    }

    // View functions
    function tokenURI(uint256 tokenID) public view override (ERC721A) returns (string memory) {
        return IERC721A(rendererContract).tokenURI(tokenID);
    }
}
