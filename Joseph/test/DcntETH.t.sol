// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DcntEth} from "../src/AccessControl/Decent/DcntETH.sol";

contract DcntETHTest is Test {
    DcntEth public dcntEth;
    address router = makeAddr("router");
        // arbitrum mainnet
    address lzEndpointArbitrum = 0x3c2269811836af69497E5F486A85D7316753cf62;

    function setUp() public {
        dcntEth = new DcntEth(lzEndpointArbitrum);

    }

    function testOwnerCanSetRouter() public {
        address owner = dcntEth.owner();
        vm.startPrank(owner);
        dcntEth.setRouter(router);
    }

    function testFuzz_RandomCanSetRouter(address caller) public {
        address owner = dcntEth.owner();
        vm.assume(owner != caller);
        vm.expectRevert();
        vm.startPrank(caller);
        dcntEth.setRouter(caller);
        
    }
}
