// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "ethfs/IFileStore.sol";
import "base64/base64.sol";
import "openzeppelin/utils/Strings.sol";
import "openzeppelin/access/Ownable.sol";

struct Peepo {
    string speedParam;
    string speedName;
    string colorParam;
    string colorName;
}

struct Color {
    string name;
    string hexCode;
}

struct Speed {
    string name;
    string param;
}

interface IPeepoToken {
    function tokenSeed(uint256 tokenID) external view returns (bytes32);
}

contract PeepoRenderer is Ownable {
    address internal _ethFileStore;
    address public peepoToken;
    string public baseSVGFileName;

    Color[] internal _colors;
    Speed[] internal _speeds;

    constructor(address _ethFS, string memory _baseSVGFileName) {
        _ethFileStore = _ethFS;
        baseSVGFileName = _baseSVGFileName;

        _colors.push(Color("Lime", "#C6FFA8"));
        _colors.push(Color("Purple", "#BFA9CA"));
        _colors.push(Color("Slate", "#A9B8CA"));
        _colors.push(Color("Burnt Orange", "#CAA9A9"));
        _colors.push(Color("Lemon Lime", "#E9FF60"));
        _colors.push(Color("Radioactive Green", "#60FFB3"));
        _colors.push(Color("Baby Blue", "#60D9FF"));
        _colors.push(Color("Blurple", "#6079FF"));
        _colors.push(Color("Hot Pink", "#FF60A3"));
        _colors.push(Color("Orangered", "#FF6767"));
        _colors.push(Color("Green", "#598C3E"));

        _speeds.push(Speed("Busted", "1s"));
        _speeds.push(Speed("Giga", "300ms"));
        _speeds.push(Speed("Ultra", "200ms"));
        _speeds.push(Speed("Hyper", "100ms"));
        _speeds.push(Speed("Normal", "500ms"));
    }

    function derivePeepo(bytes32 seed) public view returns (Peepo memory) {
        Peepo memory peepo = Peepo("", "", "", "");

        // split seed into two 16 byte halves
        bytes16 half1 = bytes16(seed);
        bytes16 half2 = bytes16(uint128(uint256(seed)));

        uint128 seed1 = uint128(half1);
        uint128 seed2 = uint128(half2);

        uint256 mod20 = seed1 % 20;
        if (mod20 > 9) {
            peepo.colorName = _colors[10].name;
            peepo.colorParam = _colors[10].hexCode;
        } else {
            peepo.colorName = _colors[mod20].name;
            peepo.colorParam = _colors[mod20].hexCode;
        }

        uint256 mod14 = seed2 % 14;
        if (mod14 > 3) {
            peepo.speedName = _speeds[4].name;
            peepo.speedParam = _speeds[4].param;
        } else {
            peepo.speedName = _speeds[mod14].name;
            peepo.speedParam = _speeds[mod14].param;
        }

        return peepo;
    }

    function renderPeepo(string memory timing, string memory fill) public view returns (string memory) {
        // get first part of svg, missing script and closing tags
        bytes memory svg = Base64.decode(IFileStore(_ethFileStore).getFile(baseSVGFileName).read());

        return string(
            Base64.encode(abi.encodePacked(svg, ":root{ --timing: ", timing, "; --fill:", fill, ";}</style></svg>"))
        );
    }

    // Debug helper
    function renderPeepoString(string memory speed, string memory fillColor) public view returns (string memory) {
        return string(Base64.decode(renderPeepo(speed, fillColor)));
    }

    function _renderAttributes(Peepo memory peepo) internal pure returns (string memory) {
        string[] memory keys = new string[](2);
        keys[0] = "Hump speed";
        keys[1] = "Color";

        string[] memory values = new string[](2);
        values[0] = peepo.speedName;
        values[1] = peepo.colorName;

        string memory attributes = "[";
        string memory separator = ",";

        for (uint256 i = 0; i < keys.length; i++) {
            if (i == keys.length - 1) {
                separator = "]";
            }

            attributes = string(
                abi.encodePacked(
                    attributes, "{\"trait_type\": \"", keys[i], "\", \"value\": \"", values[i], "\"}", separator
                )
            );
        }

        return attributes;
    }

    function tokenURIJSON(uint256 id) public view returns (string memory) {
        bytes32 seed = IPeepoToken(peepoToken).tokenSeed(id);
        Peepo memory peepo = derivePeepo(seed);

        return string(
            abi.encodePacked(
                "{",
                '"name": "peepo #',
                Strings.toString(id),
                '",',
                '"image": "data:image/svg+xml;base64,',
                renderPeepo(peepo.speedParam, peepo.colorParam),
                '","attributes":',
                _renderAttributes(peepo),
                "}"
            )
        );
    }

    function tokenURI(uint256 id) public view returns (string memory) {
        string memory json = Base64.encode(bytes(tokenURIJSON(id)));
        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    // Admin functions
    function updateBaseSVGFileName(string memory _baseSVGFileName) external onlyOwner {
        baseSVGFileName = _baseSVGFileName;
    }

    function updatePeepoToken(address _peepoToken) external onlyOwner {
        peepoToken = _peepoToken;
    }
}
