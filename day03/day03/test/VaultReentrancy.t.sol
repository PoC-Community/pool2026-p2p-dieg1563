// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "./mocks/MaliciousToken.sol";

contract VaultReentrancyTest is Test {
    Vault public vault;
    MaliciousToken public token;
    address public attacker = address(0xA11CE);
    address public owner = address(0xB0B);

    function setUp() public {
        token = new MaliciousToken();

        vm.prank(owner);
        vault = new Vault(address(token));

        token.setVault(address(vault));
        token.setAttacker(attacker);

        token.transfer(attacker, 1_000 * 10 ** 18);
    }

    function testReentrancyBlocked() public {
        uint256 depositAmount = 100 * 10 ** 18;

        vm.startPrank(attacker);
        token.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount);
        vm.stopPrank();

        token.setAttackShares(shares);
        token.setMaxAttacks(3);
        token.resetAttackCount();
        token.setAttacking(true);

        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 vaultBalanceBefore = token.balanceOf(address(vault));

        vm.prank(attacker);
        uint256 assets = vault.withdraw(shares);

        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 vaultBalanceAfter = token.balanceOf(address(vault));

        assertEq(assets, depositAmount);
        assertEq(attackerBalanceAfter, attackerBalanceBefore + depositAmount);
        assertEq(vaultBalanceAfter, vaultBalanceBefore - depositAmount);
        assertEq(vault.totalAssets(), 0);
        assertEq(vault.sharesOf(attacker), 0);
        assertEq(token.attackCount(), 1);
    }
}
