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
    address public constant FileStoreGoerli = 0x5E348d0975A920E9611F8140f84458998A53af94;

    function setUp() public {
        renderer = new PeepoRenderer(FileStoreGoerli, "pp-part2.svg");
        token = new PeepoToken(address(renderer), bytes32(0));
        token.setMintOpen(true);
    }

    function testRenderPeepo() public view {
        // console.log("peepoRenderer.renderPeepo(150, #ff0000):", )
        renderer.renderPeepo("150", "#ff0000");
    }

    function testMintSeed() public {
        token.mint(5);
        console.log("peepoToken.tokenToSeed(1):", uint256(token.tokenToSeed(5)));
    }
}
