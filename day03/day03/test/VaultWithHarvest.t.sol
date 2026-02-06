// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VaultWithHarvest.sol";
import "../src/PoolToken.sol";
import "../src/RewardToken.sol";

/**
 * @notice Mock Uniswap Router for testing
 * @dev Simulates swap behavior with a fixed ratio
 */
contract MockUniswapRouter {
    uint256 public swapRatio = 100; // 1 RWRD = 1 POOL (100%)

    function setSwapRatio(uint256 _ratio) external {
        swapRatio = _ratio;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(deadline >= block.timestamp, "Expired");

        IERC20 tokenIn = IERC20(path[0]);
        IERC20 tokenOut = IERC20(path[1]);

        uint256 amountOut = (amountIn * swapRatio) / 100;
        require(amountOut >= amountOutMin, "Slippage");

        tokenIn.transferFrom(msg.sender, address(this), amountIn);
        tokenOut.transfer(to, amountOut);

        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = amountOut;
    }

    function getAmountsOut(
        uint amountIn,
        address[] calldata
    ) external view returns (uint[] memory amounts) {
        amounts = new uint[](2);
        amounts[0] = amountIn;
        amounts[1] = (amountIn * swapRatio) / 100;
    }
}

contract VaultWithHarvestTest is Test {
    VaultWithHarvest vault;
    PoolToken poolToken;
    RewardToken rewardToken;
    MockUniswapRouter router;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        poolToken = new PoolToken(1_000_000e18);
        rewardToken = new RewardToken(1_000_000e18);

        router = new MockUniswapRouter();

        poolToken.transfer(address(router), 100_000e18);

        vault = new VaultWithHarvest(
            address(poolToken),
            address(rewardToken),
            address(router)
        );

        poolToken.transfer(alice, 10_000e18);
        poolToken.transfer(bob, 10_000e18);
    }

    function testHarvestIncreasesRatio() public {
        vm.startPrank(alice);
        poolToken.approve(address(vault), 1000e18);
        vault.deposit(1000e18);
        vm.stopPrank();

        uint256 ratioBefore = vault.currentRatio();

        rewardToken.transfer(address(vault), 100e18);

        vm.warp(block.timestamp + 1 hours);

        vault.harvest();

        uint256 ratioAfter = vault.currentRatio();
        assertGt(ratioAfter, ratioBefore, "Ratio should increase after harvest");

        vm.prank(alice);
        uint256 aliceShares = vault.sharesOf(alice);
        uint256 aliceAssets = vault.previewWithdraw(aliceShares);
        assertGt(aliceAssets, 1000e18, "Alice should have more assets than deposited");
    }
}
