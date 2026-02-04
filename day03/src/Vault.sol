// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Custom Errors
error ZeroAmount();
error InsufficientShares();
error ZeroShares();

contract Vault is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable asset;
    uint256 public totalShares;
    mapping(address => uint256) public sharesOf;

    // Events
    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);

    constructor(address _asset) {
        asset = IERC20(_asset);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        uint256 totalAssets = asset.balanceOf(address(this));
        
        // Edge case: first deposit (vault is empty)
        if (totalShares == 0) {
            return assets;
        }
        
        // Formula: shares = (assets × totalShares) / totalAssets
        // Multiply before dividing to preserve precision
        return (assets * totalShares) / totalAssets;
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        uint256 totalAssets = asset.balanceOf(address(this));
        
        // Edge case: no shares exist
        if (totalShares == 0) {
            return 0;
        }
        
        // Formula: assets = (shares × totalAssets) / totalShares
        // Multiply before dividing to preserve precision
        return (shares * totalAssets) / totalShares;
    }

    function deposit(uint256 assets) external nonReentrant returns (uint256 shares) {
        // C - CHECKS
        if (assets == 0) revert ZeroAmount();
        
        shares = _convertToShares(assets);
        if (shares == 0) revert ZeroShares();

        // E - EFFECTS
        sharesOf[msg.sender] += shares;
        totalShares += shares;

        // I - INTERACTIONS
        asset.safeTransferFrom(msg.sender, address(this), assets);

        emit Deposit(msg.sender, assets, shares);
    }

    function withdraw(uint256 shares) public nonReentrant returns (uint256 assets) {
        // C - CHECKS
        if (shares == 0) revert ZeroAmount();
        if (sharesOf[msg.sender] < shares) revert InsufficientShares();

        // E - EFFECTS
        assets = _convertToAssets(shares);
        sharesOf[msg.sender] -= shares;
        totalShares -= shares;

        // I - INTERACTIONS
        asset.safeTransfer(msg.sender, assets);

        emit Withdraw(msg.sender, assets, shares);
    }

    function withdrawAll() public returns (uint256 assets) {
        assets = withdraw(sharesOf[msg.sender]);
    }

    function previewDeposit(uint256 assets) external view returns (uint256) {
        return _convertToShares(assets);
    }

    function previewWithdraw(uint256 shares) external view returns (uint256) {
        return _convertToAssets(shares);
    }
}
