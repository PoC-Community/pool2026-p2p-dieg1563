// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Simple test ERC20 token
contract TestToken is ERC20 {
    constructor() ERC20("Test Token", "TEST") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }
}

contract VaultTest is Test {
    Vault public vault;
    TestToken public token;
    address public alice = address(0x1);
    address public owner = address(0x2);

    function setUp() public {
        token = new TestToken();
        
        vm.prank(owner);
        vault = new Vault(address(token));
        
        // Transfer tokens to alice and owner for testing
        token.transfer(alice, 10_000 * 10 ** 18);
        token.transfer(owner, 10_000 * 10 ** 18);
    }

    // Test: totalAssets returns correct vault balance
    function testTotalAssets() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        assertEq(vault.totalAssets(), 1000 * 10 ** 18);
    }

    // Test: currentRatio with initial deposit
    function testCurrentRatioInitial() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // 1 share = 1 asset, so ratio should be 1e18
        assertEq(vault.currentRatio(), 1e18);
    }

    // Test: currentRatio with reward
    function testCurrentRatioAfterReward() public {
        // Alice deposits 1000 tokens
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // Owner adds 100 tokens as reward
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(owner);
        vault.addReward(100 * 10 ** 18);
        
        // Ratio should be 1.1e18 (1100 assets / 1000 shares * 1e18)
        assertEq(vault.currentRatio(), 1.1e18);
    }

    // Test: assetsOf returns correct user balance
    function testAssetsOf() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // Alice should have 1000 assets worth of shares
        assertEq(vault.assetsOf(alice), 1000 * 10 ** 18);
    }

    // Test: assetsOf increases after reward
    function testAssetsOfAfterReward() public {
        // Alice deposits 1000 tokens
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // Owner adds 100 tokens as reward
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(owner);
        vault.addReward(100 * 10 ** 18);
        
        // Alice's shares should now be worth 1100 tokens
        assertEq(vault.assetsOf(alice), 1100 * 10 ** 18);
    }

    // Test: Full reward flow - deposit, reward, withdraw
    function testRewardFlow() public {
        // 1. Alice deposits 1000 tokens
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        uint256 shares = vault.deposit(1000 * 10 ** 18);
        
        // 2. Alice receives 1000 shares
        assertEq(shares, 1000 * 10 ** 18);
        assertEq(vault.sharesOf(alice), 1000 * 10 ** 18);
        
        // 3. Owner adds 100 tokens as reward
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(owner);
        vault.addReward(100 * 10 ** 18);
        
        // 4. Ratio is now 1.1
        assertEq(vault.currentRatio(), 1.1e18);
        
        // 5. Alice withdraws all shares
        vm.prank(alice);
        uint256 assets = vault.withdrawAll();
        
        // 6. Alice receives 1100 tokens (more than she deposited!)
        assertEq(assets, 1100 * 10 ** 18);
    }

    // Test: addReward restricted to owner
    function testAddRewardOnlyOwner() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // Non-owner tries to add reward
        vm.prank(alice);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(alice);
        vm.expectRevert();
        vault.addReward(100 * 10 ** 18);
    }

    // Test: Cannot add zero reward
    function testAddRewardZeroAmount() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // Owner tries to add zero reward
        vm.prank(owner);
        vm.expectRevert(ZeroAmount.selector);
        vault.addReward(0);
    }

    // Test: Cannot add reward to empty vault
    function testAddRewardNoStakers() public {
        // Owner tries to add reward to empty vault
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(owner);
        vm.expectRevert(NoStakers.selector);
        vault.addReward(100 * 10 ** 18);
    }

    // Test: RewardAdded event is emitted
    function testRewardAddedEvent() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit Vault.RewardAdded(100 * 10 ** 18);
        vault.addReward(100 * 10 ** 18);
    }

    // Test: Multiple rewards accumulate
    function testMultipleRewards() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // First reward
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        vm.prank(owner);
        vault.addReward(100 * 10 ** 18);
        
        // Second reward
        vm.prank(owner);
        token.approve(address(vault), 50 * 10 ** 18);
        vm.prank(owner);
        vault.addReward(50 * 10 ** 18);
        
        // Total assets should be 1000 + 100 + 50 = 1150
        assertEq(vault.totalAssets(), 1150 * 10 ** 18);
        
        // Alice's assets should be 1150
        assertEq(vault.assetsOf(alice), 1150 * 10 ** 18);
    }

    // Test: Preview functions work correctly
    function testPreviewFunctions() public {
        vm.prank(alice);
        token.approve(address(vault), 1000 * 10 ** 18);
        
        vm.prank(alice);
        vault.deposit(1000 * 10 ** 18);
        
        // Add reward
        vm.prank(owner);
        token.approve(address(vault), 100 * 10 ** 18);
        
        vm.prank(owner);
        vault.addReward(100 * 10 ** 18);
        
        // previewDeposit should show correct share amount
        uint256 previewShares = vault.previewDeposit(100 * 10 ** 18);
        // 100 assets * 1000 shares / 1100 assets = ~90.909... shares
        assertTrue(previewShares > 0);
        
        // previewWithdraw should show correct asset amount
        uint256 previewAssets = vault.previewWithdraw(1000 * 10 ** 18);
        // 1000 shares * 1100 assets / 1000 shares = 1100 assets
        assertEq(previewAssets, 1100 * 10 ** 18);
    }
}
