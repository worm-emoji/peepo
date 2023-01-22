// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {DSTest} from "ds-test/test.sol";
import {Vm} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {PeepoRenderer} from "../src/PeepoRenderer.sol";
import {PeepoToken} from "../src/PeepoToken.sol";
import "base64/base64.sol";

contract PeepoRendererTest is DSTest {
    PeepoRenderer internal renderer;
    PeepoToken internal token;
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    function setUp() public {
        renderer = new PeepoRenderer(vm.readFileBinary("./art/peepo-7.chunk"));
        token = new PeepoToken(address(renderer), bytes32(0));
        renderer.updatePeepoToken(address(token));
        token.setMintOpen(true);
    }

    function testRenderPeepo() public view {
        console.log("peepoRenderer.renderPeepo(150, #ff0000):", renderer.renderPeepoString("150", "#ff0000"));
    }

    function testMintSeed() public {
        token.mint(5);

        console.log("peepoToken.tokenToSeed(1):", uint256(token.tokenSeed(5)));
    }

    function testPeepoTokenMetadata() public {
        token.mint(5);
        console.log("peepoToken.tokenURIJSON(1):", renderer.tokenURIJSON(1));
    }
}
