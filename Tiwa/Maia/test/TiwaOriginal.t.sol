//SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {VirtualAccount} from "@omni/VirtualAccount.sol";
import {PayableCall, Call} from "@omni/interfaces/IVirtualAccount.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./ulysses-omnichain/helpers/ImportHelper.sol";


contract VirtualAccountTest is Test {

    address public alice;
    address public bob;
    address token;

    VirtualAccount public vAcc;

    function setUp() public {
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        token = address(new ERC20("W","w"));

        // create new VirtualAccount for user Alice and this test contract as mock local port
        vAcc = new VirtualAccount(alice, address(this));
    }


  

    function testPayableCall(address fuzzAddress) public {
        vm.assume(fuzzAddress != alice);
        PayableCall[] memory calls = new PayableCall[](1);
        calls[0].target = token;
        calls[0].callData = abi.encodeCall(ERC20.balanceOf, (bob));
        vm.expectRevert();
        vm.prank(fuzzAddress);
        vAcc.payableCall(calls);
    }
    
}