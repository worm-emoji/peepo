// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ethfs/IFileStore.sol";
import "base64/base64.sol";

contract PeepoRenderer {
    address public peepoToken;
    address public ethFileStore;

    constructor(address _peepoToken, address _ethFileStore) {
        peepoToken = _peepoToken;
        ethFileStore = _ethFileStore;
    }

    function renderPeepo(string memory speed, string memory fillColor) public view returns (string memory) {
        // get first part of svg, missing script and closing tags
        string memory svg = IFileStore(ethFileStore).getFile("pp-part2.svg").read();
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
}
