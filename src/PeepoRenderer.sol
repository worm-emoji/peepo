// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ethfs/IFileStore.sol";
import "base64/base64.sol";
import "openzeppelin/utils/Strings.sol";
import "openzeppelin/access/Ownable.sol";

contract PeepoRenderer is Ownable {
    address internal ethFileStore;
    string public baseSVGFileName;

    constructor(address _ethFileStore, string memory _baseSVGFileName) {
        ethFileStore = _ethFileStore;
        baseSVGFileName = _baseSVGFileName;
    }

    function renderPeepo(string memory speed, string memory fillColor) public view returns (string memory) {
        // get first part of svg, missing script and closing tags
        string memory svg = IFileStore(ethFileStore).getFile(baseSVGFileName).read();
        // Pass in speed and color as arguments to the script
        bytes memory js = abi.encodePacked(
            "e(\"\",\".f\",\"repeat\",",
            speed,
            "*Math.random(),0);document.querySelectorAll(\".bodyfill\").forEach((x) => { x.setAttribute(\"fill\",\"",
            fillColor,
            "\"); });\n//]]>\n</script>\n</svg>"
        );
        svg = string(abi.encodePacked(svg, Base64.encode(js)));

        return string(svg);
    }

    // Debug helper
    function renderPeepoString(string memory speed, string memory fillColor) public view returns (string memory) {
        return string(Base64.decode(renderPeepo(speed, fillColor)));
    }

    function tokenURI(uint256 id) public view returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        "{",
                        '"name": "peepo #',
                        Strings.toString(id),
                        '",',
                        '"image": "data:image/svg+xml;base64,',
                        renderPeepo(Strings.toString(id), "#ff0000"),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Admin functions
    function updateBaseSVGFileName(string memory _baseSVGFileName) external onlyOwner {
        baseSVGFileName = _baseSVGFileName;
    }
}
