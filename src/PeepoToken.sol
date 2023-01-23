// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ERC721A/ERC721A.sol";
import {MerkleProofLib} from "solady/utils/MerkleProofLib.sol";
import "openzeppelin/access/Ownable.sol";
import "./IERC4906.sol";

contract PeepoToken is ERC721A, IERC4906, Ownable {
    address public rendererContract;
    bool public mintOpen;
    bytes32 public merkleRoot;
    mapping(uint256 => bytes32) internal _tokenSeeds;

    error MintClosed();
    error NotAllowlisted();
    error OnlyOwnerOrMetadataContract();

    constructor(address _rendererContract, bytes32 _merkleRoot) ERC721A("peepo in chain", "PEEPO") {
        rendererContract = _rendererContract;
        merkleRoot = _merkleRoot;
    }

    function _isAllowlisted(address _wallet, bytes32[] calldata _proof) internal view returns (bool) {
        return MerkleProofLib.verify(_proof, merkleRoot, keccak256(abi.encodePacked(_wallet)));
    }

    function mint(uint256 quantity) external payable {
        if (!mintOpen) revert MintClosed();
        // todo: check price
        _mint(msg.sender, quantity);
    }

    function mintAllowlist(uint256 quantity, bytes32[] calldata proof) external payable {
        if (!mintOpen) revert MintClosed();
        // todo: check price
        if (!_isAllowlisted(msg.sender, proof)) revert NotAllowlisted();

        _mint(msg.sender, quantity);
    }

    function _startTokenId() internal pure override(ERC721A) returns (uint256) {
        return 1;
    }

    function _beforeTokenTransfers(address from, address, uint256 startTokenId, uint256 quantity)
        internal
        override(ERC721A)
    {
        // only do something if minting
        if (from != address(0)) return;

        // when tokens are minted, generate a seed for each token
        for (uint256 i = 0; i < quantity; i++) {
            uint256 tokenId = startTokenId + i;
            _tokenSeeds[tokenId] = keccak256(abi.encodePacked(block.difficulty, tokenId, msg.sender));
        }
    }

    // owner functions
    function updateRendererContract(address _rendererContract) external onlyOwner {
        emit BatchMetadataUpdate(_startTokenId(), _nextTokenId());
        rendererContract = _rendererContract;
    }

    function setMintOpen(bool _mintOpen) external onlyOwner {
        mintOpen = _mintOpen;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdraw() external onlyOwner {
        payable(this.owner()).transfer(address(this).balance);
    }

    // renderer contract functions
    function triggerBatchMetadataUpdate() external {
        if (msg.sender != rendererContract || msg.sender != owner()) revert OnlyOwnerOrMetadataContract();
        emit BatchMetadataUpdate(_startTokenId(), _nextTokenId());
    }

    function triggerMetadataUpdate(uint256 _tokenId) external {
        if (msg.sender != rendererContract || msg.sender != owner()) revert OnlyOwnerOrMetadataContract();
        emit MetadataUpdate(_tokenId);
    }

    // View functions
    function tokenURI(uint256 tokenID) public view override(ERC721A) returns (string memory) {
        return IERC721A(rendererContract).tokenURI(tokenID);
    }

    function tokenSeed(uint256 tokenID) public view returns (bytes32) {
        if (ownerOf(tokenID) == address(0)) revert URIQueryForNonexistentToken();
        return _tokenSeeds[tokenID];
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC165 interface ID for ERC165.
            || interfaceId == 0x80ac58cd // ERC165 interface ID for ERC721.
            || interfaceId == 0x49064906 // ERC165 interface ID for ERC4906
            || interfaceId == 0x5b5e139f; // ERC165 interface ID for ERC721Metadata.
    }
}
