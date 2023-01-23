// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "base64/base64.sol";
import "openzeppelin/utils/Strings.sol";
import "openzeppelin/access/Ownable.sol";
import "solady/utils/SSTORE2.sol";

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
    function triggerMetadataUpdate(uint256 _tokenId) external;
    function triggerBatchMetadataUpdate() external;
}

contract PeepoRenderer is Ownable {
    address public baseSVGPointer;
    address public peepoToken;
    string public baseSVGFileName;

    Color[] internal _colors;
    Speed[] internal _speeds;

    constructor(address _baseSVGPointer) {
        baseSVGPointer = _baseSVGPointer;

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
        _speeds.push(Speed("HYPER", "100ms"));
        _speeds.push(Speed("ULTRA", "150ms"));
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

        mod20 = seed2 % 50;
        if (mod20 == 0) {
            // 1/50 == 2% == TIRED
            peepo.speedName = _speeds[0].name;
            peepo.speedParam = _speeds[0].param;
        } else if (mod20 > 0 && mod20 < 3) {
            // 2/50 == 4% == BUSTED
            peepo.speedName = _speeds[1].name;
            peepo.speedParam = _speeds[1].param;
        } else if (mod20 >= 3 && mod20 < 5) {
            // 2/50 == 4% == HYPER
            peepo.speedName = _speeds[2].name;
            peepo.speedParam = _speeds[2].param;
        } else if (mod20 >= 6 && mod20 < 13) {
            // 7/50 == 14% == ULTRA
            peepo.speedName = _speeds[3].name;
            peepo.speedParam = _speeds[3].param;
        } else {
            // 37/50 == 74% == PUMP
            peepo.speedName = _speeds[4].name;
            peepo.speedParam = _speeds[4].param;
        }

        return peepo;
    }

    function renderPeepo(string memory timing, string memory fill) public view returns (string memory) {
        // get first part of svg, missing script and closing tags
        bytes memory svg = SSTORE2.read(baseSVGPointer);

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
    function updateBaseSVG(bytes memory _baseSVG) external onlyOwner {
        IPeepoToken(peepoToken).triggerBatchMetadataUpdate();
        baseSVGPointer = SSTORE2.write(_baseSVG);
    }

    function updatePeepoToken(address _peepoToken) external onlyOwner {
        peepoToken = _peepoToken;
    }
}
