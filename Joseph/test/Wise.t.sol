// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PendlePowerFarmToken, SimpleERC20} from "../src/UncheckedExternalCall/WiseLending/MockTransferContract.sol";
 

contract WiseTest is Test {
    PendlePowerFarmToken FarmToken;
    SimpleERC20 weirdToken;

   
    function setUp() public {
    weirdToken = new SimpleERC20();

    FarmToken = new PendlePowerFarmToken(address(weirdToken));
     }

    function testFuzzTransfer(address user, uint amount) public{
        vm.assume(amount > 0);
      assertEq (weirdToken.balanceOf(user), 0);
      vm.startPrank(user);
      vm.expectRevert();
      FarmToken.addCompoundRewards(amount);
       
    }
   
}
