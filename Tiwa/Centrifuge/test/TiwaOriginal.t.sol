// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.21;

import "./TestSetup.t.sol";

contract LiquidityPoolTest is TestSetup {
    // Deployment
    function testDeployment(
        uint64 poolId,
        string memory tokenName,
        string memory tokenSymbol,
        bytes16 trancheId,
        uint128 currencyId
    ) public {
        vm.assume(currencyId > 0);

        address lPool_ = deployLiquidityPool(poolId, erc20.decimals(), tokenName, tokenSymbol, trancheId, currencyId);
        LiquidityPool lPool = LiquidityPool(lPool_);

        // values set correctly
        assertEq(address(lPool.investmentManager()), address(investmentManager));
        assertEq(lPool.asset(), address(erc20));
        assertEq(lPool.poolId(), poolId);
        assertEq(lPool.trancheId(), trancheId);
        address token = poolManager.getTrancheToken(poolId, trancheId);
        assertEq(address(lPool.share()), token);
        assertEq(_bytes128ToString(_stringToBytes128(tokenName)), _bytes128ToString(_stringToBytes128(lPool.name())));
        assertEq(_bytes32ToString(_stringToBytes32(tokenSymbol)), _bytes32ToString(_stringToBytes32(lPool.symbol())));

        // permissions set correctly
        assertEq(lPool.wards(address(root)), 1);
        // assertEq(investmentManager.wards(self), 0); // deployer has no permissions
    }


    function testfuzzdeposit(address random, uint64 validUntil, uint64 poolId, uint8 decimals, string memory tokenName, string memory tokenSymbol, bytes16 trancheId) public {
        uint128 price = 2 * 10 ** 27;
        uint128 currencyId = 1;
        uint256 amount = 10000;
    
    
        vm.assume(validUntil >= block.timestamp);


        address lPool_ = deployLiquidityPool(poolId, erc20.decimals(), tokenName, tokenSymbol, trancheId, currencyId);
        LiquidityPool lPool = LiquidityPool(lPool_);
        homePools.updateTrancheTokenPrice(poolId, trancheId, currencyId, price);

        erc20.mint(self, amount);

      
        homePools.updateMember(poolId, trancheId, self, validUntil); // add user as member

       
        // success
        erc20.approve(address(investmentManager), amount); // add allowance
        lPool.requestDeposit(amount, self);

        // trigger executed collectInvest
        uint128 _currencyId = poolManager.currencyAddressToId(address(erc20)); // retrieve currencyId
        uint128 trancheTokensPayout = uint128(amount * 10 ** 27 / price); // trancheTokenPrice = 2$
        homePools.isExecutedCollectInvest(
            poolId, trancheId, bytes32(bytes20(self)), _currencyId, uint128(amount), trancheTokensPayout
        );


        //make msg.sender random address to demonstrate that any usercan call deposit for a particular address. see explanation in bug pattern.
     vm.expectRevert();   
     vm.startPrank(random);

        //Random account can call deposit for another address
        uint256 share = 2;
        lPool.deposit(amount / 2, self);
    }

}
