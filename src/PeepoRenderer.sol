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
    string param;
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

        _colors.push(Color("NEON G", "#58FF00"));
        _colors.push(Color("PURP", "#BFA9CA"));
        _colors.push(Color("POWDER", "#A9B8CA"));
        _colors.push(Color("CHICKEN BREAST", "#CAA9A9"));
        _colors.push(Color("LEMON", "#E9FF60"));
        _colors.push(Color("SICKLY", "#60FFB3"));
        _colors.push(Color("G-FUEL", "#60D9FF"));
        _colors.push(Color("ROYAL LITE", "#6079FF"));
        _colors.push(Color("JUICY", "#FF60A3"));
        _colors.push(Color("GUAVA", "#FF6767"));
        _colors.push(Color("GREEN", "#598C3E"));

        _speeds.push(Speed("TIRED", "2s"));
        _speeds.push(Speed("BUSTED", "1s"));
        _speeds.push(Speed("ULTRA", "150ms"));
        _speeds.push(Speed("HYPER", "100ms"));
        _speeds.push(Speed("PUMP", "200ms"));
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
            peepo.colorParam = _colors[10].param;
        } else if (mod20 == 0) {
            if (mod20 % 2 == 0) {
                peepo.colorName = _colors[0].name;
                peepo.colorParam = _colors[0].param;
            } else {
                peepo.colorName = _colors[1].name;
                peepo.colorParam = _colors[1].param;
            }
        } else {
            peepo.colorName = _colors[mod20].name;
            peepo.colorParam = _colors[mod20].param;
        }

        uint256 mod14 = seed2 % 14;

        if (mod14 < 3 && (mod14 != 0 || (mod14 == 0 && mod14 % 4 == 0))) {
            peepo.speedName = _speeds[mod14].name;
            peepo.speedParam = _speeds[mod14].param;
        } else {
            peepo.speedName = _speeds[4].name;
            peepo.speedParam = _speeds[4].param;
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
        keys[0] = "HUMP SPEED";
        keys[1] = "COLOR";

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
