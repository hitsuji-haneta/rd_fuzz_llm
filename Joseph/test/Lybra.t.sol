// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Configurator} from "../src/AccessControl/Lybra/LybraConfig.sol";
import {GovernanceTimelock} from "../src/AccessControl/Lybra/GovernanceTimelock.sol";


contract LybraTest is Test {
    Configurator public config;
    GovernanceTimelock public timelock;
    address deployerAdmin = makeAddr("deployer");

    function setUp() public {
        vm.startPrank(deployerAdmin);
        address[] memory t = new address[](1);
        t[0] = address(0);
        timelock = new GovernanceTimelock(1,t, t, deployerAdmin);
        config = new Configurator(address(timelock), makeAddr("_curvePool"));
        vm.stopPrank();
    }



    function testFuzz_RandomCanSetRouter(address caller) public {
        address dao = address(config);
        vm.assume(dao != caller);
        vm.assume(deployerAdmin != caller);

      vm.expectRevert();
        vm.startPrank(caller);
        config.setProtocolRewardsPool(caller);
        
    }
}
